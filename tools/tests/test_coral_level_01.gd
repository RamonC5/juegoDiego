extends "res://tools/tests/test_forest_route.gd"
## Controles reales para todo el recorrido. Se aísla el combate durante la navegación.


func _run() -> void:
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1280, 720)
	var entrance: Control = load("res://game/boot/entrance.tscn").instantiate()
	entrance.initial_page = &"map"
	root.add_child(entrance)
	current_scene = entrance
	await step(4)
	entrance.world_map.world_buttons[1].pressed.emit()
	await step(8)
	main = current_scene as Node2D
	if not check(main != null and main.stage is CoralStage, "El mapa abre Costa de Coral"):
		quit(1)
		return
	hero = main.player
	stage = main.stage
	var storage: String = "user://coral01-%d-%d.json" % [OS.get_process_id(), Time.get_ticks_usec()]
	main.progress = LevelProgress.new(storage)
	check(main._hud_title.text == "2–1" and stage.DEFINITION.key_definition.theme_id == &"coral",
		"Nivel 2–1 y llaves de coral")
	check(stage.level_keys.size() == 3 and stage.checkpoint_positions().size() == 3,
		"Exactamente tres llaves y tres faroles")
	check(stage.moving_platforms.size() == 5, "Cinco balsas físicas")
	check(await _check_goteron(), "Goterón patrulla, causa daño lateral y admite pisotón")
	hero.respawn(stage.DEFINITION.spawn)
	hero.invulnerability = 100000.0
	hero.health = 2
	hero.collision_mask = 1
	hero.foot_sensor.collision_mask = 0
	for enemy in stage.enemies:
		if is_instance_valid(enemy):
			enemy.set_physics_process(false)
			enemy.collision_layer = 0
			enemy._contact.monitoring = false
	await step(10)
	var ferry_index: int = 0
	for region in range(16):
		var x: float = stage.DEFINITION.region_starts[region].x
		if region in [4, 8, 12]:
			if not check(await _move_to(x + 180) and stage.active_checkpoint_index == region / 4 - 1 and hero.health == 2,
					"Farol %d por contacto físico sin curación" % (region / 4)):
				_finish()
				return
		if region in [2, 6, 9, 12, 14]:
			if not check(await _cross_ferry(stage.moving_platforms[ferry_index]), "Balsa %d de muelle a muelle" % (ferry_index + 1)):
				_finish()
				return
			ferry_index += 1
		if region in [4, 10]:
			if not check(await _cross_rocks(x), "Cruce de charcos por rocas"):
				_finish()
				return
		if region in [3, 7, 13]:
			if not check(await _collect_key(x), "Ascenso y recogida física de la llave %d" % ([3, 7, 13].find(region) + 1)):
				_finish()
				return
		if region == 8:
			if not check(await _cross_roof(), "La ruta principal pasa por encima de la gruta"):
				_finish()
				return
	check(not stage._secret_life_taken() and hero.health == 2, "La gruta es opcional")
	check(await _move_to(stage.DEFINITION.goal.x - 20) and stage.completed, "Las tres llaves permiten completar el nivel")
	check(LevelProgress.new(storage).is_completed("world_02_level_01"), "La victoria se guarda por ID")
	print("COSTA 2-1: %.1f segundos de ruta automática sin combate." % stage.seconds)
	main.queue_free()
	await step(3)
	main = load(WorldCatalog.CORAL_SCENE).instantiate()
	main.collection_progress = CollectionProgress.new(storage + ".collection")
	root.add_child(main)
	hero = main.player
	stage = main.stage
	hero.respawn(stage.DEFINITION.secret_grove + Vector2(-70, 0))
	check(await _check_grotto(), "Entrada baja, vida única y retorno por las rocas")
	_finish()


func _check_goteron() -> bool:
	var enemy: ForestEnemy = stage.enemies[0]
	var start: float = enemy.position.x
	await step(35)
	if enemy.kind != "goteron" or not enemy.has_visible_art() or absf(enemy.position.x - start) < 10 or enemy.can_see_player():
		return false
	var health: int = hero.health
	hero.controls.set_virtual_axis(1.0)
	for frame in 200:
		await step(1)
		if hero.health < health:
			break
	hero.controls.clear_virtual()
	if hero.health == health:
		return false
	enemy.set_physics_process(false)
	hero.respawn(enemy.position - Vector2(0, 180))
	await step(50)
	return not enemy.active


func _move_to(x: float, limit: int = 1800) -> bool:
	hero.controls.automatic_run = true
	hero.controls.full_jump = true
	for frame in limit:
		if stage.completed:
			return true
		if hero.dead:
			return false
		var diff: float = x - hero.position.x
		if absf(diff) < 8.0:
			hero.controls.set_virtual_axis(0)
			await step(8)
			return true
		hero.controls.set_virtual_axis(signf(diff))
		await step(1)
	hero.controls.set_virtual_axis(0)
	return false


func _cross_ferry(ferry: ForestMovingPlatform) -> bool:
	var left: float = ferry.definition.start_position.x - 156
	var right: float = ferry.definition.end_position.x + 156
	if not await _move_to(left - 29):
		return false
	for frame in 850:
		if ferry.position.x < ferry.definition.start_position.x + 4:
			break
		await step(1)
	hero.controls.request_tap_jump()
	for frame in 75:
		var diff: float = ferry.position.x - hero.position.x
		hero.controls.set_virtual_axis(signf(diff) if absf(diff) > 13 else 0.0)
		await step(1)
		if ferry.carries(hero):
			break
	hero.controls.clear_virtual()
	if not ferry.carries(hero):
		return false
	for frame in 800:
		if ferry.position.x > ferry.definition.end_position.x - 8:
			return await jump_to(right + 45, 600)
		await step(1)
	return false


func _cross_rocks(x: float) -> bool:
	return await _move_to(x + 1518) \
		and await jump_to(x + 1705, 620) \
		and await jump_to(x + 1908, 557) \
		and await jump_to(x + 2125, 620) \
		and await jump_to(x + 2305, 600)


func _collect_key(x: float) -> bool:
	var count: int = stage.collected_keys.size()
	if not await _move_to(x + 1335) or not await jump_to(x + 1480, 512):
		return false
	if not await _move_to(x + 1648) or not await jump_to(x + 1802, 415):
		return false
	if not await _move_to(x + 2028) or not await jump_to(x + 2182, 325):
		return false
	return await _move_to(x + 2295) and stage.collected_keys.size() == count + 1 \
		and await _move_to(x + 2900)


func _cross_roof() -> bool:
	var x: float = stage.DEFINITION.secret_grove.x
	return await _move_to(x - 268) and await jump_to(x - 151, 508) \
		and await _move_to(x - 96) and await jump_to(x + 70, 430) \
		and await _move_to(x + 1292) and await jump_to(x + 1580, 600)


func _check_grotto() -> bool:
	var x: float = stage.DEFINITION.secret_grove.x
	await step(8)
	hero.controls.set_virtual_axis(1)
	await step(35)
	if hero.position.x >= x:
		return false
	hero.controls.set_virtual_action(&"crouch", true)
	for frame in 260:
		await step(1)
		if hero.position.y > 640:
			break
	hero.controls.clear_virtual()
	await step(48)
	if hero.position.y < 840 or hero.dead:
		return false
	if not await _move_to(x + 920) or not stage._secret_life_taken() or hero.maximum_health != 4:
		return false
	if not await _move_to(x + 1118) or not await jump_to(x + 1235, 762) \
		or not await _move_to(x + 1283) or not await jump_to(x + 1403, 684) \
		or not await _move_to(x + 1450) or not await jump_to(x + 1585, 600) or hero.dead:
		return false
	hero.respawn(Vector2(x + 920, 855))
	await step(8)
	return stage._secret_life_taken() and hero.maximum_health == 4
