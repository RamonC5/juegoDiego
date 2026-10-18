extends SceneTree
## Plataformas del bosque y muerte/retorno físico por los nueve portones anteriores a faroles.
var main: Node2D
var checks: int = 0
var failures: int = 0
var jumps: int = 0

func _initialize() -> void:
	run.call_deferred()

func step(count: int = 1) -> void:
	for frame in count:
		await physics_frame
		await process_frame

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
	print("%s %s" % ["OK" if ok else "FALLO", message])

func touch(point: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = 81
	event.position = point
	event.pressed = pressed
	root.push_input(event, true)

func drag(point: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = 81
	event.position = point
	root.push_input(event, true)

func activate(gate: ForestRootGate) -> void:
	for station in gate.definition.stations:
		for target in main.stage.throw_targets:
			if target.definition.mechanism_id == station.mechanism_id:
				target.break_apart()
				target.activated.emit(station.mechanism_id)

func run() -> void:
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1280, 720)
	main = load("res://game/boot/main.tscn").instantiate()
	root.add_child(main)
	await step(5)
	var hero: DiegoPlayer = main.player
	var stage: ForestStage = main.stage
	for enemy in stage.enemies:
		enemy.set_physics_process(false)
		enemy.collision_layer = 0
		enemy._contact.monitoring = false
		enemy._stomp.collision_layer = 0
	main.settings.show_touch = true
	main.settings.left_handed = false
	main._apply_settings()
	main.touch.refresh()
	hero.jumped.connect(func(): jumps += 1)
	hero.respawn(Vector2(740, 600))
	await step(4)
	hero.controls.set_virtual_action(&"crouch", true)
	await step(4)
	check(hero.crouching and hero.is_on_floor(), "agacharse bajo la primera plataforma real mantiene el suelo")
	hero.controls.clear_virtual()
	await step(4)
	check(not hero.crouching and hero.can_stand() and absf(hero.position.y - 600) < 0.2, "soltar abajo permite ponerse de pie debajo de una plataforma atravesable")
	var right := Vector2(950, 450)
	touch(right, true)
	drag(right + Vector2(0, 65))
	await step(3)
	check(hero.crouching, "el contacto táctil baja la postura bajo la plataforma real")
	drag(right + Vector2(0, 5))
	await step(4)
	check(not hero.crouching and hero.position.distance_to(Vector2(740, 600)) < 0.5 and jumps == 0, "deslizar arriba con el mismo dedo recupera la postura sin saltar ni desplazarse")
	drag(right + Vector2(0, 65))
	await step(3)
	check(hero.crouching, "el mismo contacto permite volver a agacharse sin levantar el dedo")
	drag(right + Vector2(0, 5))
	await step(3)
	check(not hero.crouching and jumps == 0, "alternar abajo y arriba no deja saltos ni posturas bloqueadas")
	touch(right + Vector2(0, 5), false)
	# La consulta no puede ignorar un techo sólido por encontrar primero la repisa.
	hero.controls.set_virtual_action(&"crouch", true)
	await step(3)
	var roof := StaticBody2D.new()
	roof.position = Vector2(740, 529)
	var roof_shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(160, 20)
	roof_shape.shape = box
	roof.add_child(roof_shape)
	stage.add_child(roof)
	await step(3)
	hero.controls.clear_virtual()
	await step(3)
	check(hero.crouching and not hero.can_stand(), "una pared sólida sigue bloqueando la cápsula aunque también haya una repisa unilateral")
	hero.controls.set_virtual_axis(-1)
	for frame in 100:
		await step()
		if not hero.crouching:
			break
	check(not hero.crouching and hero.position.x < 642 and hero.is_on_floor(), "un techo sólido permite salir agachado y levantarse al quedar libre")
	roof.queue_free()
	hero.respawn(Vector2(740, 600))
	await step(4)
	hero.controls.request_tap_jump()
	var high: float = 600
	for frame in 80:
		await step()
		high = minf(high, hero.position.y)
	check(high < 515 and hero.is_on_floor() and absf(hero.position.y - 515) < 0.2, "poder levantarse por debajo conserva el salto y el aterrizaje encima de la misma plataforma")
	# Recorrido hacia delante hasta cada farol; muerte real, menú y retorno por el portón.
	for index in stage.root_gates.size() - 1:
		var gate: ForestRootGate = stage.root_gates[index]
		var checkpoint: int = index + 3
		activate(gate)
		hero.respawn(gate.position - Vector2(130, 0))
		hero.invulnerability = 1000
		await step(4)
		hero.controls.automatic_run = true
		hero.controls.set_virtual_axis(1)
		for frame in 170:
			await step()
			if stage.active_checkpoint_index >= checkpoint and hero.position.x > stage.checkpoint_positions()[checkpoint].x + 50:
				break
		hero.controls.clear_virtual()
		check(stage.active_checkpoint_index == checkpoint, "portón %d: caminar activa el farol posterior real" % index)
		activate(stage.root_gates[index + 1])
		if index == 0:
			# Inyección de desincronización: la copia consolidada debe reconstruirla.
			gate.reset_closed()
			stage.activated_mechanisms.clear()
		hero._die()
		await step(62)
		check(paused and hero.dead, "portón %d: la derrota abre el menú habitual" % index)
		main._resume()
		await step(4)
		check(gate.is_open and gate._shape.disabled and gate.activated.size() == 2, "portón %d: el farol restaura marcas, dibujo y colisión abiertos" % index)
		check(not stage.root_gates[index + 1].is_open and stage.root_gates[index + 1].activated.is_empty(), "portón %d: lo posterior al farol vuelve a cero" % index)
		hero.invulnerability = 1000
		hero.controls.automatic_run = true
		hero.controls.set_virtual_axis(-1)
		for frame in 170:
			await step()
			if hero.position.x < gate.position.x - 90:
				break
		check(hero.position.x < gate.position.x - 90 and not hero.dead, "portón %d: puede volver físicamente a las dianas de la otra orilla" % index)
		hero.controls.clear_virtual()
	# Un farol avanzado debe restaurar también una apertura mucho más antigua.
	stage.root_gates[0].reset_closed()
	hero._die()
	await step(62)
	main._resume()
	await step(3)
	check(stage.root_gates[0].is_open and stage.root_gates[0]._shape.disabled, "morir de nuevo en el último farol conserva también el primer portón")
	main.queue_free()
	await step(3)
	await preload("res://tools/tests/audio_cleanup.gd").flush(self)
	print("RECUPERACIÓN REAL: %d comprobaciones, %d fallos" % [checks, failures])
	quit(1 if failures else 0)
