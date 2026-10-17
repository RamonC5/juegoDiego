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
	main.level_definition = preload("res://tools/tests/fixtures/forest_mechanics.tres")
	root.add_child(main)
	main.progress = LevelProgress.new("user://forest-test-progress.json")
	DirAccess.remove_absolute("user://forest-test-progress.json")
	main.progress.levels.clear()
	await _step(10)
	var hero: DiegoPlayer = main.player
	var stage: ForestStage = main.stage
	_check(hero.is_on_floor() and not hero.dead, "Diego aparece sobre suelo sólido")
	_check(stage.enemies.size() == 9, "nueve patrullas de Terrón y Moflete")
	_check(stage.total_leaves > 50 and stage.collectibles.size() == stage.total_leaves + 3, "hojas y tres cristales opcionales")
	_check(stage.DEFINITION.level_id == "world_01_level_01", "identificador estable del primer mundo")
	_check(not stage.checkpoint_active and not stage.completed, "nivel nuevo sin completar")
	_check(stage.level_keys.size() == 3 and stage.collected_keys.is_empty(), "el intento empieza con tres llaves pendientes")
	_check(not stage.exit_door.is_open, "la puerta empieza cerrada")
	stage._on_goal(hero)
	_check(not stage.completed and main.progress.levels.is_empty(), "cero llaves no permite completar ni guardar el nivel")
	var first_key: LevelKey = stage.level_keys[0]
	var outsider := Node2D.new()
	first_key._on_body_entered(outsider)
	outsider.free()
	_check(not first_key.taken, "un cuerpo ajeno al jugador no recoge llaves")
	hero.dead = true
	first_key._on_body_entered(hero)
	hero.dead = false
	_check(not first_key.taken, "Diego derrotado no puede recoger una llave")
	hero.respawn(first_key.position + Vector2(0, 49))
	await _step(5)
	_check(first_key.taken and stage.collected_keys.size() == 1, "contacto físico recoge automáticamente la primera llave")
	_check(not first_key.visible and not first_key.monitoring, "la llave recogida desaparece y desactiva su sensor")
	first_key._on_body_entered(hero)
	_check(stage.collected_keys.size() == 1, "la misma llave no cuenta dos veces")
	var impostor := LevelKey.new()
	impostor.slot = 1
	impostor.taken = true
	stage._on_key_collected(impostor)
	impostor.free()
	_check(stage.collected_keys.size() == 1, "una llave ajena al nivel no aumenta el contador")
	stage._on_goal(hero)
	_check(not stage.completed and not stage.exit_door.is_open, "una llave mantiene bloqueada la salida")
	_check(main._key_counter.text == "1 / 3" and main._keys_card.accessibility_description.contains("Llave 1 recogida"), "el HUD combina icono, cantidad y descripción de llaves recogidas")
	hero.respawn(stage.DEFINITION.goal - Vector2(220, 0))
	hero.controls.set_virtual_axis(1)
	await _step(70)
	hero.controls.clear_virtual()
	_check(hero.position.x < stage.DEFINITION.goal.x - 65 and not stage.completed, "la puerta cerrada bloquea físicamente el paso")
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
	# Los dos encuentros añadidos también deben ser alcanzables por pisotón físico.
	for index in [7, 8]:
		var extra: ForestEnemy = stage.enemies[index]
		hero.respawn(extra.position + Vector2(0, -155))
		hero.velocity.y = 150.0
		await _step(35)
		_check((not is_instance_valid(extra) or not extra.active) and hero.health == 3,
			"el encuentro adicional %d se elimina por un pisotón real sin daño lateral" % (index - 6))
	# Aproximación lateral: el contacto debe causar daño una vez, con protección.
	var second: ForestEnemy = stage.enemies[1]
	second.set_physics_process(true)
	hero.respawn(second.position + Vector2(-120, 0))
	hero.controls.automatic_run = true
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
	# Resolver las dianas mediante recogida, animación de lanzamiento e impacto reales.
	for index in stage.bridges.size():
		hero.respawn(stage.DEFINITION.bridges[index].pine_position + Vector2(0, 26))
		hero.controls.set_virtual_axis(1)
		await _step(2)
		hero.controls.set_virtual_axis(0)
		await _step(4)
		for _action in 2:
			hero.controls.set_virtual_action(&"grab_throw", true)
			await _step(1)
			hero.controls.set_virtual_action(&"grab_throw", false)
			await _step(25)
		await _step(65)
		_check(stage.bridges[index].state == RootBridge.State.OPEN, "diana %d abre su puente mediante un lanzamiento real" % (index + 1))
	# Huecos pequeños y puentes abiertos permiten cruzar sin teletransportes en vuelo.
	for index in stage.DEFINITION.ground_sections.size() - 1:
		var edge: float = stage.DEFINITION.ground_sections[index].end.x
		var next_edge: float = stage.DEFINITION.ground_sections[index + 1].position.x
		hero.respawn(Vector2(edge - 34, 600))
		hero.controls.automatic_run = false
		await _step(3)
		hero.controls.set_virtual_axis(1)
		hero.velocity.x = hero.tuning.walk_speed
		hero.controls.set_virtual_action(&"jump", true)
		await _step(maxi(68, ceili((next_edge - edge + 120.0) / hero.tuning.walk_speed * 60.0)))
		hero.controls.clear_virtual()
		_check(not hero.dead and hero.is_on_floor() and hero.position.x > next_edge,
			"paso %d accesible con el puente correspondiente abierto" % (index + 1))
	# Comprobar el acceso real a la ruta alta, atravesando la plataforma desde abajo.
	hero.respawn(Vector2(750, 600))
	await _step(3)
	hero.controls.set_virtual_action(&"jump", true)
	await _step(48)
	hero.controls.clear_virtual()
	_check(hero.is_on_floor() and absf(hero.position.y - 515) < 2, "plataforma opcional permite subir desde abajo y aterrizar encima")
	hero.respawn(Vector2(stage.level_keys[1].position.x, 600))
	await _step(3)
	hero.controls.set_virtual_action(&"jump", true)
	await _step(48)
	hero.controls.clear_virtual()
	_check(stage.level_keys[1].taken and stage.collected_keys.size() == 2, "la segunda llave se alcanza saltando desde el suelo")
	stage._on_goal(hero)
	_check(not stage.completed and not stage.exit_door.is_open, "dos llaves tampoco permiten completar el nivel")
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
	_check(stage.collected_keys.size() == 2 and stage.level_keys[0].taken and stage.level_keys[1].taken, "volver al farol conserva las dos llaves sin duplicarlas")
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
		if hero.position.x > 6200.0 and not stage.level_keys[2].taken:
			_check(await preload("res://tools/tests/moving_platform_route.gd").reach_third_key(main), "la tercera llave se alcanza viajando y saltando desde el tronco")
			hero.controls.automatic_run = true
			hero.controls.set_virtual_axis(1)
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
					if distance > 0.0 and distance < 125.0 and absf(hero.position.y - enemy.position.y) < 65.0:
						needs_jump = true
			for key in stage.level_keys:
				var distance: float = key.position.x - hero.position.x
				if not key.taken and hero.position.y - key.position.y > 100.0 and distance > 0.0 and distance < 180.0:
					needs_jump = true
			if needs_jump:
				hero.controls.set_virtual_action(&"jump", true)
		await _step(1)
		if stage.completed or hero.dead:
			break
	hero.controls.clear_virtual()
	if not stage.completed:
		print("DIAGNÓSTICO RUTA: posición=", hero.position, " muerto=", hero.dead, " llaves=", stage.collected_keys)
	_check(stage.completed and not hero.dead, "se puede recorrer todo el nivel con movimiento y saltos reales")
	_check(stage.collected_keys.size() == 3 and stage.exit_door.is_open, "la tercera llave abre la puerta antes de completar")
	_check(main._result.get("keys", 0) == 3, "el resultado registra las tres llaves obligatorias")
	var last_leaf: ForestCollectible
	for collectible in stage.collectibles:
		if not collectible.crystal and (last_leaf == null or collectible.position.x > last_leaf.position.x):
			last_leaf = collectible
	_check(last_leaf.taken, "la última hoja se recoge antes de que la meta detenga al jugador")
	_check(hero.celebrating, "llegar a la salida reproduce victoria")
	_check(main.progress.levels.get(stage.DEFINITION.level_id, {}).get("completed", false), "meta guarda la finalización")
	var old_result: Dictionary = main.progress.levels.get(stage.DEFINITION.level_id, {}).duplicate()
	stage._on_goal(hero)
	_check(main.progress.levels.get(stage.DEFINITION.level_id, {}) == old_result, "la meta solo registra una finalización por partida")
	var storage := LevelProgress.new("user://forest-test-progress.json")
	_check(storage.levels.has(stage.DEFINITION.level_id), "guardado se recupera desde disco")
	_check(storage.levels.get(stage.DEFINITION.level_id, {}).get("best_keys", 0) == 3, "el guardado conserva las tres llaves del resultado")
	storage.record_completion(stage.DEFINITION.level_id, {"leaves": 0, "crystals": 0, "seconds": 9999.0})
	var best: Dictionary = storage.levels.get(stage.DEFINITION.level_id, {})
	_check(int(best.get("best_leaves", -1)) == int(old_result.get("best_leaves", -2)), "rejugar no borra las mejores hojas")
	# JSON puede redondear por debajo de la resolución de la física (1/60 s).
	_check(float(best.get("best_seconds", 0)) <= float(old_result.get("best_seconds", 0)) + 0.0001, "rejugar conserva el mejor tiempo")
	_check(best.get("unlocked", false) and int(best.get("completions", 0)) == 2, "nivel completado permanece desbloqueado y rejugable")
	_check(best.get("best_keys", 0) == 3, "un resultado antiguo sin llaves no borra las mejores llaves")
	DirAccess.remove_absolute("user://forest-test-progress.json")
	main.queue_free()
	paused = false
	await _step(2)
	var replay: Node2D = load("res://game/boot/main.tscn").instantiate()
	root.add_child(replay)
	await _step(3)
	_check(replay.stage.collected_keys.is_empty() and not replay.stage.exit_door.is_open, "reiniciar o rejugar exige conseguir tres llaves nuevas")
	_check(replay.stage.level_keys.all(func(key: LevelKey): return key.visible and not key.taken), "el reinicio repone las tres llaves")
	replay.progress = LevelProgress.new("user://keys-sensor-test-progress.json")
	replay.progress.levels.clear()
	var duplicate_slots: Array[int] = [0, 0, 1]
	replay.stage.exit_door.set_keys(duplicate_slots)
	_check(not replay.stage.exit_door.is_open, "la puerta rechaza tres entradas con una ranura duplicada")
	var invalid_slots: Array[int] = [-1, 0, 1, 3]
	replay.stage.exit_door.set_keys(invalid_slots)
	_check(not replay.stage.exit_door.is_open, "los identificadores fuera de las tres ranuras no abren la puerta")
	var empty_slots: Array[int] = []
	replay.stage.exit_door.set_keys(empty_slots)
	# Situar llaves de prueba junto a la salida permite verificar el sensor continuo.
	replay.player.respawn(replay.stage.DEFINITION.goal - Vector2(100, 0))
	await _step(3)
	for index in 2:
		replay.stage.level_keys[index].position = replay.player.position + Vector2(0, -49)
	await _step(5)
	_check(replay.stage.collected_keys.size() == 2 and not replay.stage.completed, "dos contactos junto a la salida aún no completan")
	replay.stage.level_keys[2].position = replay.player.position + Vector2(0, -49)
	await _step(6)
	_check(replay.stage.completed and replay.stage.exit_door.is_open, "la tercera llave abre estando ya dentro del sensor de salida")
	DirAccess.remove_absolute("user://keys-sensor-test-progress.json")
	replay.queue_free()
	await _step(2)
	print("RESULTADO BOSQUE: %d comprobaciones, %d fallos" % [_checks, _failures])
	quit(0 if _failures == 0 else 1)


