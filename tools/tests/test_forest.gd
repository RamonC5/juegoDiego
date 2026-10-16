extends SceneTree
## Integración del nivel: física, combate, checkpoint, resultados y recorrido completo.

var _checks: int = 0
var _failures: int = 0
var main: Node2D


func _initialize() -> void:
	_run.call_deferred()


func _step(count: int) -> void:
	for _index in count:
		await physics_frame
		await process_frame


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
	print("%s %s" % ["OK" if condition else "FALLO", description])


func _run() -> void:
	root.size = Vector2i(1280, 720)
	main = load("res://game/boot/main.tscn").instantiate()
	root.add_child(main)
	main.progress = LevelProgress.new("user://forest-test-progress.json")
	DirAccess.remove_absolute("user://forest-test-progress.json")
	main.progress.levels.clear()
	await _step(10)
	var hero: DiegoPlayer = main.player
	var stage: ForestStage = main.stage
	_check(hero.is_on_floor() and not hero.dead, "Diego aparece sobre suelo sólido")
	_check(stage.enemies.size() == 7, "siete patrullas de Terrón y Moflete")
	_check(stage.total_leaves > 50 and stage.collectibles.size() == stage.total_leaves + 3, "hojas y tres cristales opcionales")
	_check(stage.DEFINITION.level_id == "world_01_level_01", "identificador estable del primer mundo")
	_check(not stage.checkpoint_active and not stage.completed, "nivel nuevo sin completar")
	for enemy in stage.enemies:
		enemy.set_physics_process(false)
	# Un pisotón real debe rebotar y anular el daño del enemigo.
	var first: ForestEnemy = stage.enemies[0]
	var bounces: Array[int] = [0]
	hero.bounced.connect(func(): bounces[0] += 1)
	hero.respawn(first.position + Vector2(0, -155))
	hero.velocity.y = 150.0
	await _step(35)
	_check(not is_instance_valid(first) or not first.active, "pisotón elimina la patrulla")
	_check(bounces[0] == 1 and hero.health == 3, "pisotón produce un solo rebote y conserva energía")
	# Aproximación lateral: el contacto debe causar daño una vez, con protección.
	var second: ForestEnemy = stage.enemies[1]
	second.set_physics_process(true)
	hero.respawn(second.position + Vector2(-120, 0))
	hero.controls.set_virtual_axis(1)
	await _step(38)
	hero.controls.clear_virtual()
	_check(hero.health == 2, "contacto lateral resta una energía y protege de impactos repetidos")
	second.set_physics_process(false)
	# El enemigo recibe el contrato arrojadizo existente mediante un barrido físico.
	hero.respawn(Vector2(1850, 600))
	var object := ThrowableObject.new()
	object.definition = ThrowableCatalog.DEFINITIONS[3]
	stage.add_child(object)
	var hand := Marker2D.new()
	hand.position = second.position + Vector2(-180, -45)
	stage.add_child(hand)
	object.pick_up(hand)
	object.release(1, Vector2.ZERO)
	await _step(40)
	_check(not is_instance_valid(second) or not second.active, "objeto lanzado elimina al enemigo por contacto real")
	var leaf: ForestCollectible = stage.collectibles[0]
	hero.respawn(leaf.position + Vector2(0, 38))
	await _step(4)
	_check(stage.leaves > 0 and leaf.taken, "hoja se recoge al tocarla")
	var before: int = stage.leaves
	leaf._on_body_entered(hero)
	_check(stage.leaves == before, "una hoja no se puede contabilizar dos veces")
	# Las cuatro brechas se cruzan andando, con salto completo, sin teletransporte en vuelo.
	for index in stage.DEFINITION.ground_sections.size() - 1:
		var edge: float = stage.DEFINITION.ground_sections[index].end.x
		hero.respawn(Vector2(edge - 34, 600))
		hero.controls.automatic_run = false
		await _step(3)
		hero.controls.set_virtual_axis(1)
		hero.velocity.x = hero.tuning.walk_speed
		hero.controls.set_virtual_action(&"jump", true)
		await _step(68)
		hero.controls.clear_virtual()
		_check(not hero.dead and hero.is_on_floor() and hero.position.x > edge + 120,
			"brecha %d accesible caminando" % (index + 1))
	# Comprobar el acceso real a la ruta alta, atravesando la plataforma desde abajo.
	hero.respawn(Vector2(750, 600))
	await _step(3)
	hero.controls.set_virtual_action(&"jump", true)
	await _step(48)
	hero.controls.clear_virtual()
	_check(hero.is_on_floor() and absf(hero.position.y - 515) < 2, "plataforma opcional permite subir desde abajo y aterrizar encima")
	hero.respawn(stage.DEFINITION.checkpoint)
	await _step(4)
	_check(stage.checkpoint_active, "cruzar el farol activa el punto de control")
	var collected_before_death: int = stage.leaves
	hero.position.y = 1250.0
	await _step(62)
	_check(hero.dead and paused, "caer fuera del nivel abre el reintento en pausa")
	main._resume()
	await _step(3)
	_check(not hero.dead and hero.health == 3 and hero.position.distance_to(stage.respawn_position) < 3, "reanudar vuelve al farol con energía completa")
	_check(stage.leaves == collected_before_death, "reintentar conserva lo recogido en el intento")
	var clock: float = stage.seconds
	main._toggle_pause()
	await _step(8)
	_check(is_equal_approx(clock, stage.seconds), "pausa detiene el tiempo de nivel")
	main._toggle_pause()
	# Recorrido completo con entradas del jugador. Se salta al aproximarse a enemigos y huecos.
	hero.respawn(stage.DEFINITION.spawn)
	hero.controls.automatic_run = true
	hero.controls.set_virtual_axis(1)
	for _frame in 2200:
		if hero.is_on_floor():
			hero.controls.set_virtual_action(&"jump", false)
			var needs_jump: bool = false
			for section in stage.DEFINITION.ground_sections:
				var distance: float = section.end.x - hero.position.x
				if distance > 0.0 and distance < 54.0 and section.end.x < stage.DEFINITION.width:
					needs_jump = true
			for enemy in stage.enemies:
				if is_instance_valid(enemy) and enemy.active:
					var distance: float = enemy.position.x - hero.position.x
					if distance > 0.0 and distance < 125.0:
						needs_jump = true
			if needs_jump:
				hero.controls.set_virtual_action(&"jump", true)
		await _step(1)
		if stage.completed or hero.dead:
			break
	hero.controls.clear_virtual()
	_check(stage.completed and not hero.dead, "se puede recorrer todo el nivel con movimiento y saltos reales")
	_check(hero.celebrating, "llegar a la salida reproduce victoria")
	_check(main.progress.levels.get(stage.DEFINITION.level_id, {}).get("completed", false), "meta guarda la finalización")
	var old_result: Dictionary = main.progress.levels.get(stage.DEFINITION.level_id, {}).duplicate()
	stage._on_goal(hero)
	_check(main.progress.levels.get(stage.DEFINITION.level_id, {}) == old_result, "la meta solo registra una finalización por partida")
	var storage := LevelProgress.new("user://forest-test-progress.json")
	_check(storage.levels.has(stage.DEFINITION.level_id), "guardado se recupera desde disco")
	storage.record_completion(stage.DEFINITION.level_id, {"leaves": 0, "crystals": 0, "seconds": 9999.0})
	var best: Dictionary = storage.levels.get(stage.DEFINITION.level_id, {})
	_check(int(best.get("best_leaves", -1)) == int(old_result.get("best_leaves", -2)), "rejugar no borra las mejores hojas")
	# JSON puede redondear por debajo de la resolución de la física (1/60 s).
	_check(float(best.get("best_seconds", 0)) <= float(old_result.get("best_seconds", 0)) + 0.0001, "rejugar conserva el mejor tiempo")
	_check(best.get("unlocked", false) and int(best.get("completions", 0)) == 2, "nivel completado permanece desbloqueado y rejugable")
	DirAccess.remove_absolute("user://forest-test-progress.json")
	main.queue_free()
	paused = false
	await _step(2)
	print("RESULTADO BOSQUE: %d comprobaciones, %d fallos" % [_checks, _failures])
	quit(0 if _failures == 0 else 1)
