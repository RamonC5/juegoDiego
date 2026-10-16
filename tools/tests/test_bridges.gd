extends SceneTree
## Pruebas del reto obligatorio: impactos físicos, gesto real, recuperación y ruta completa.

var main: Node2D
var _checks: int = 0
var _failures: int = 0
const STORAGE: String = "user://bridge-test-progress.json"


func _initialize() -> void:
	_run.call_deferred()


func _step(count: int) -> void:
	for _frame in count:
		await physics_frame
		await process_frame


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
	print("%s %s" % ["OK" if condition else "FALLO", description])


func _objects() -> int:
	var count: int = 0
	for node in main.find_children("*", "", true, false):
		if node is ThrowableObject:
			count += 1
	return count


func _new_level() -> void:
	if is_instance_valid(main):
		main.queue_free()
		paused = false
		await _step(3)
	main = load("res://game/boot/main.tscn").instantiate()
	root.add_child(main)
	main.progress = LevelProgress.new(STORAGE)
	main.settings.show_touch = true
	main._apply_settings()
	main.touch.refresh()
	await _step(8)


func _act(tactile: bool = true, pointer: int = 70) -> void:
	if tactile:
		var point: Vector2 = Vector2(root.size.x * (0.25 if main.settings.left_handed else 0.75), root.size.y * 0.72)
		var press := InputEventScreenTouch.new()
		press.index = pointer
		press.position = point
		press.pressed = true
		main.touch._unhandled_input(press)
		await _step(2)
		press = press.duplicate()
		press.pressed = false
		main.touch._input(press)
	else:
		var key := InputEventKey.new()
		key.physical_keycode = KEY_E
		key.keycode = KEY_E
		key.pressed = true
		Input.parse_input_event(key)
		await _step(2)
		key = key.duplicate()
		key.pressed = false
		Input.parse_input_event(key)
	await _step(24)


func _face(direction: float) -> void:
	main.player.controls.set_virtual_axis(direction)
	await _step(2)
	main.player.controls.set_virtual_axis(0.0)
	await _step(5)


func _jump_to(x: float) -> void:
	var hero: DiegoPlayer = main.player
	hero.controls.automatic_run = false
	hero.controls.full_jump = true
	hero.controls.set_virtual_action(&"jump", false)
	await _step(2)
	hero.controls.set_virtual_action(&"jump", true)
	for frame in 100:
		var difference: float = x - hero.position.x
		hero.controls.set_virtual_axis(signf(difference) if absf(difference) > 5.0 else 0.0)
		await _step(1)
		if frame > 15 and hero.is_on_floor() and absf(difference) < 12.0:
			break
	hero.controls.clear_virtual()
	await _step(5)


func _travel_to(x: float) -> bool:
	# Recorrer sin teletransportes: saltos ante huecos pequeños, enemigos y llaves elevadas.
	var hero: DiegoPlayer = main.player
	var stage: ForestStage = main.stage
	hero.controls.automatic_run = true
	hero.controls.full_jump = true
	for _frame in 2400:
		if hero.dead or stage.completed:
			break
		if hero.position.x >= x - 4.0:
			hero.controls.clear_virtual()
			await _step(8)
			return not hero.dead
		hero.controls.set_virtual_axis(1)
		if hero.is_on_floor():
			hero.controls.set_virtual_action(&"jump", false)
			var jump: bool = false
			for section in stage.DEFINITION.ground_sections:
				var distance: float = section.end.x - hero.position.x
				if distance > 0.0 and distance < 54.0 and section.end.x < stage.DEFINITION.width:
					jump = true
			for enemy in stage.enemies:
				if is_instance_valid(enemy) and enemy.active:
					var distance: float = enemy.position.x - hero.position.x
					if distance > 0.0 and distance < 125.0 and absf(hero.position.y - enemy.position.y) < 65.0:
						jump = true
			for key in stage.level_keys:
				var distance: float = key.position.x - hero.position.x
				if not key.taken and hero.position.y - key.position.y > 100.0 and distance > 0.0 and distance < 180.0:
					jump = true
			if jump:
				hero.controls.set_virtual_action(&"jump", true)
		await _step(1)
	hero.controls.clear_virtual()
	if not stage.completed:
		print("DIAGNÓSTICO RUTA: posición=", hero.position, " muerto=", hero.dead, " energía=", hero.health, " llaves=", stage.collected_keys)
	return stage.completed and not hero.dead


func _run() -> void:
	root.size = Vector2i(1280, 720)
	DirAccess.remove_absolute(STORAGE)
	await _new_level()
	var hero: DiegoPlayer = main.player
	var stage: ForestStage = main.stage
	var practice: RootBridge = stage.bridges[0]
	var target: ForestThrowTarget = stage.throw_targets[0]
	var pine: ThrowableObject = stage.pine_stations[0]
	_check(stage.bridges.size() == 2 and stage.throw_targets.size() == 2, "dos estaciones conectadas con identificadores distintos")
	_check(stage.pine_stations.size() == 2 and pine.definition.object_id == &"pina_bosque", "piñas reales del catálogo en ambos puestos")
	_check(stage.checkpoint_positions().size() == 3 and stage.active_checkpoint_index == -1, "tres faroles nuevos sin activar")
	_check(practice.state == RootBridge.State.CLOSED and practice._shape.disabled, "ensayo cerrado sin suelo invisible")
	_check(stage.bridges[1].state == RootBridge.State.CLOSED and stage.bridges[1]._shape.disabled, "puente de la llave cerrado sin colisión")
	_check(target.collision_layer == 64 and not (hero.collision_mask & 64), "la diana recibe proyectiles y no bloquea el cuerpo de Diego")
	var total: int = _objects()
	target.receive_thrown_hit(pine)
	_check(target.active and stage.activated_mechanisms.is_empty(), "una piña libre no activa la diana")
	# Intentar saltar el ensayo deja a Diego en el suelo inferior y no permite evitarlo.
	hero.respawn(Vector2(2820, 600))
	await _step(3)
	hero.controls.full_jump = true
	hero.controls.automatic_run = true
	hero.controls.set_virtual_axis(1)
	hero.velocity.x = hero.tuning.run_speed
	hero.controls.set_virtual_action(&"jump", true)
	await _step(115)
	hero.controls.clear_virtual()
	await _step(10)
	_check(not hero.dead and hero.is_on_floor() and hero.position.y > 730, "fallar el ensayo tiene suelo inferior seguro")
	_check(hero.position.x < practice.definition.bridge_rect.end.x, "carrera y salto completo no permiten eludir la pasarela")
	# Acercarse andando al primer peldaño antes de saltar; no exigir un salto de 300 px.
	hero.controls.automatic_run = false
	hero.controls.set_virtual_axis(-1)
	for _frame in 100:
		if hero.position.x < 3055.0:
			break
		await _step(1)
	hero.controls.clear_virtual()
	await _step(6)
	await _jump_to(2955)
	_check(hero.is_on_floor() and absf(hero.position.y - 740) < 3, "primer apoyo de recuperación alcanzable con salto real")
	await _jump_to(2890)
	_check(hero.is_on_floor() and absf(hero.position.y - 660) < 3, "segundo apoyo devuelve hacia el puesto")
	await _jump_to(2790)
	_check(hero.is_on_floor() and absf(hero.position.y - 600) < 3, "regreso físico a la orilla de lanzamiento")
	hero.respawn(Vector2(2540, 600))
	await _step(5)
	await _face(1)
	await _act()
	_check(hero.held_object == pine and pine.state == ThrowableObject.State.HELD, "el toque de la zona de acción recoge la piña")
	target.receive_thrown_hit(pine)
	_check(target.active, "una piña sostenida no activa el mecanismo")
	await _step(270)
	_check(hero.held_object == pine and _objects() == total, "sostener más de cuatro segundos no devuelve ni duplica la piña")
	await _face(-1)
	await _act()
	await _step(65)
	_check(target.active and practice.state == RootBridge.State.CLOSED, "un lanzamiento fallado conserva el reto pendiente")
	var return_time: float = pine._return_time
	var clock: float = stage.seconds
	main._toggle_pause()
	await _step(60)
	_check(is_equal_approx(return_time, pine._return_time) and is_equal_approx(clock, stage.seconds), "la pausa detiene reposición y reloj")
	main._resume()
	await _step(260)
	_check(pine.state == ThrowableObject.State.FREE and absf(pine.position.x - 2540.0) < 1, "la piña fallada regresa a su puesto")
	_check(_objects() == total, "reponer mantiene exactamente las mismas instancias")
	pine.position = Vector2(2000, 500)
	await _step(2)
	_check(absf(pine.position.x - 2540.0) < 1, "perder la piña fuera del área local la recupera")
	hero.respawn(Vector2(2540, 600))
	await _step(4)
	await _face(1)
	await _act()
	hero.take_damage(hero.position + Vector2(150, 0))
	_check(hero.held_object == null and pine._return_time > 0, "soltar por daño programa recuperación de la herramienta")
	await _step(260)
	_check(pine.state == ThrowableObject.State.FREE and absf(pine.position.x - 2540.0) < 1, "la suelta por daño vuelve al puesto sin bloqueo")
	hero.respawn(Vector2(2540, 600))
	await _step(4)
	await _face(1)
	# Lados invertidos: el mismo gesto sigue funcionando sin botones fijos.
	main.settings.left_handed = true
	main.touch.refresh()
	await _act()
	_check(hero.held_object == pine, "coger funciona con las zonas táctiles intercambiadas")
	await _act()
	for _frame in 45:
		if not target.active:
			break
		await _step(1)
	_check(not target.active and practice.state == RootBridge.State.OPENING, "el lanzamiento táctil impacta físicamente y empieza el despliegue")
	_check(practice._shape.disabled, "la apertura no publica suelo antes de completar el dibujo")
	var progress: float = practice._progress
	main._toggle_pause()
	await _step(55)
	_check(is_equal_approx(progress, practice._progress) and practice._shape.disabled, "pausar durante la apertura congela dibujo y colisión pendiente")
	main._resume()
	await _step(50)
	_check(practice.state == RootBridge.State.OPEN and not practice._shape.disabled, "al terminar aparece una pasarela transitable")
	_check(stage.activated_mechanisms == [&"puente_diana_ensayo"], "el primer impacto abre solo su estación")
	stage._on_mechanism_activated(&"puente_diana_ensayo")
	_check(stage.activated_mechanisms.size() == 1, "una activación repetida no duplica estado")
	hero.respawn(Vector2(3050, 560))
	await _step(24)
	_check(hero.is_on_floor() and absf(hero.position.y - 600.0) < 2, "Diego aterriza sobre la colisión del puente abierto")
	hero.respawn(stage.DEFINITION.checkpoint)
	await _step(5)
	_check(stage.active_checkpoint_index == 1, "el farol previo al puente principal cambia la reaparición")
	# El salto máximo tampoco evita el reto principal: caer vuelve al farol seguro.
	hero.respawn(Vector2(3760, 600))
	await _step(3)
	hero.controls.set_virtual_axis(1)
	hero.controls.automatic_run = true
	hero.velocity.x = hero.tuning.run_speed
	hero.controls.set_virtual_action(&"jump", true)
	await _step(130)
	_check(hero.dead and paused and not stage.level_keys[1].taken, "el puente principal cerrado impide saltar hasta la llave")
	main._resume()
	await _step(4)
	_check(not hero.dead and hero.position.distance_to(stage.respawn_position) < 4, "el reintento aparece sobre suelo del último farol")
	_check(practice.state == RootBridge.State.OPEN and stage.bridges[1].state == RootBridge.State.CLOSED, "morir conserva solo las aperturas ya resueltas")
	# Otro objeto válido también sirve: contrato de impacto físico, sin exigir un tipo exclusivo.
	var alternate := ForestThrowTarget.new()
	alternate.definition = stage.DEFINITION.bridges[1].duplicate()
	alternate.definition.mechanism_id = &"test_barrel"
	alternate.definition.target_position = Vector2(800, 300)
	stage.add_child(alternate)
	var barrel := ThrowableObject.new()
	barrel.definition = ThrowableCatalog.DEFINITIONS[0]
	stage.add_child(barrel)
	var hand := Marker2D.new()
	hand.position = Vector2(570, 310)
	stage.add_child(hand)
	barrel.pick_up(hand)
	barrel.release(1, Vector2.ZERO)
	await _step(40)
	_check(not alternate.active, "un barril lanzado también puede activar una diana")
	alternate.queue_free()
	barrel.queue_free()
	hand.queue_free()
	_check(LevelProgress.new(STORAGE).levels.is_empty(), "resolver un puente no guarda una finalización ni inventa guardado de intento")
	# Muerte a mitad del segundo despliegue: restaurar abierto antes de continuar.
	stage._on_mechanism_activated(&"puente_diana_principal")
	await _step(8)
	_check(stage.bridges[1].state == RootBridge.State.OPENING, "segundo despliegue independiente en curso")
	hero._die()
	main._toggle_pause()
	await _step(8)
	main._resume()
	await _step(3)
	_check(stage.bridges[1].state == RootBridge.State.OPEN and not stage.bridges[1]._shape.disabled,
		"morir durante el despliegue restaura el puente abierto y seguro")
	_check(not stage.throw_targets[1].active and _objects() == total, "restaurar sincroniza diana y objetos sin duplicación")
	hero.respawn(stage.checkpoint_positions()[0])
	await _step(5)
	_check(stage.active_checkpoint_index == 1, "volver a un farol anterior no hace retroceder la reaparición")
	# Nueva partida: las dos estaciones deben poder resolverse dentro del recorrido completo.
	await _new_level()
	hero = main.player
	stage = main.stage
	main.settings.left_handed = false
	main.touch.refresh()
	_check(stage.activated_mechanisms.is_empty() and stage.bridges.all(func(b: RootBridge): return b.state == RootBridge.State.CLOSED),
		"reiniciar rearma ambos mecanismos y mantiene las llaves pendientes")
	_check(await _travel_to(2540), "ruta inicial hasta la piña sin teletransportes")
	_check(stage.level_keys[0].taken, "la ruta inicial recoge la primera llave")
	await _face(1)
	await _act(true)
	_check(hero.held_object == stage.pine_stations[0], "el ensayo se recoge al llegar por el recorrido real")
	await _act(true)
	await _step(65)
	_check(stage.bridges[0].state == RootBridge.State.OPEN, "el ensayo se resuelve dentro de la aventura")
	_check(await _travel_to(3430), "cruce real de la pasarela y llegada al segundo puesto")
	await _face(1)
	await _act(false)
	_check(hero.held_object == stage.pine_stations[1], "la tecla E recoge la piña del puente principal")
	await _act(false)
	await _step(65)
	_check(stage.bridges[1].state == RootBridge.State.OPEN, "la tecla E lanza y activa el puente de la llave")
	_check(await _travel_to(4840), "cruzar, saltar a la plataforma y alcanzar el farol posterior")
	_check(stage.level_keys[1].taken and stage.collected_keys.size() == 2, "la segunda llave se consigue por el recorrido del puente")
	_check(not stage.exit_door.is_open and not stage.completed, "dos llaves mantienen cerrada la salida")
	_check(stage.active_checkpoint_index == 2, "el farol posterior conserva el avance de la llave")
	_check(await _travel_to(stage.DEFINITION.goal.x), "aventura completa con movimiento, gestos, lanzamientos y saltos reales")
	_check(stage.completed and stage.collected_keys.size() == 3 and stage.exit_door.is_open,
		"tercera llave y puerta completan el nivel una sola vez")
	_check(main.progress.levels.get(stage.DEFINITION.level_id, {}).get("best_keys", 0) == 3,
		"el resultado final conserva las tres llaves en disco")
	main.queue_free()
	paused = false
	await _step(3)
	DirAccess.remove_absolute(STORAGE)
	print("RESULTADO PUENTES: %d comprobaciones, %d fallos" % [_checks, _failures])
	quit(0 if _failures == 0 else 1)
