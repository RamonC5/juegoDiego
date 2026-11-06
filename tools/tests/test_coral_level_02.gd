extends "res://tools/tests/test_coral_level_01.gd"
## Navegación física de 2-2, desde el selector hasta la salida.

const LEVEL := "world_02_level_02"
const SELECTOR := preload("res://game/boot/coral_adventures.tscn")
var _storage: String


func _run() -> void:
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1280, 720)
	_storage = "user://coral02-%d-%d.json" % [OS.get_process_id(), Time.get_ticks_usec()]
	var progress := LevelProgress.new(_storage)
	var menu: ForestAdventureMenu = SELECTOR.instantiate()
	menu.progress = progress
	root.add_child(menu)
	current_scene = menu
	await step(3)
	check(menu.level_buttons.size() == 2 and not menu.level_buttons[0].disabled
		and menu.level_buttons[1].disabled, "Perfil nuevo: 2-1 disponible y 2-2 bloqueada")
	menu._request_level(LEVEL)
	check(current_scene == menu and not menu._loading, "El selector rechaza un acceso bloqueado")
	check(progress.record_completion("world_02_level_01", {"seconds": 250, "keys": 3}) == OK,
		"Guardar 2-1 con el esquema existente")
	menu.queue_free()
	await step(3)
	menu = SELECTOR.instantiate()
	menu.progress = LevelProgress.new(_storage)
	root.add_child(menu)
	current_scene = menu
	await step(3)
	check(not menu.level_buttons[0].disabled and "Rejugar" in menu.level_buttons[0].text,
		"La primera fase queda disponible para rejugar")
	check(not menu.level_buttons[1].disabled and menu.level_buttons[1].has_focus(),
		"El selector lee el guardado y enfoca 2-2")
	menu.level_buttons[1].pressed.emit()
	await step(8)
	main = current_scene as Node2D
	if not check(main != null and main.stage is CoralStage, "El selector abre la escena de 2-2"):
		quit(1)
		return
	var selected_scene: PackedScene = load(main.scene_file_path)
	main.queue_free()
	await step(3)
	main = selected_scene.instantiate()
	main.collection_progress = CollectionProgress.new(_storage + ".collection")
	root.add_child(main)
	current_scene = main
	stage = main.stage
	hero = main.player
	main.progress = LevelProgress.new(_storage)
	check(main._hud_title.text == "2–2" and stage.DEFINITION.level_id == LEVEL, "HUD e ID propios")
	check(stage.checkpoint_positions().size() == 3 and stage.level_keys.size() == 3
		and not stage.exit_door.is_open, "Tres faroles y salida cerrada antes de recoger las tres llaves")
	check(stage.moving_platforms.size() == 12, "Nueve elevadores y tres balsas")
	# La regresión de 2-1 comprueba el mismo enemigo con daño lateral y pisotón.
	hero.invulnerability = 100000.0
	hero.health = 2
	hero.collision_mask = 1
	hero.foot_sensor.collision_mask = 0
	for enemy in stage.enemies:
		enemy.set_physics_process(false)
		enemy.collision_layer = 0
		enemy._contact.monitoring = false
	await step(10)

	var next_platform: int = 0
	for index in stage.DEFINITION.region_starts.size():
		var x: float = stage.DEFINITION.region_starts[index].x
		if index in [4, 8, 12]:
			if not check(await _move_to(x + 190) and stage.active_checkpoint_index == index / 4 - 1
					and hero.health == 2 and hero.maximum_health == 3, "Farol %d sin curación" % (index / 4)):
				_finish()
				return
		if index == 1:
			if not check(await _check_practice_lift(stage.moving_platforms[next_platform], x),
					"Elevador de ensayo y cristal opcional en la terraza"):
				_finish()
				return
			next_platform += 1
		if index in [2, 7, 10, 13]:
			var left: ForestMovingPlatform = stage.moving_platforms[next_platform]
			var right: ForestMovingPlatform = stage.moving_platforms[next_platform + 1]
			var keys_before: int = stage.collected_keys.size()
			if not check(await _cross_high_dock(left, right, 1.0, index), "Muelle alto del tramo %d" % index):
				_finish()
				return
			check(stage.collected_keys.size() == keys_before + int(index != 10), "Recogida de llaves en los muelles")
			check(stage.exit_door.is_open == (index == 13), "La salida exige las tres llaves")
			if index == 10:
				if not check(await _cross_high_dock(right, left, -1.0) and await _cross_high_dock(left, right, 1.0),
						"Los elevadores permiten retroceder y retomar la ruta"):
					_finish()
					return
			next_platform += 2
		if index in [3, 6, 11]:
			if not check(await _cross_pools(x + 1250), "Cruce de las tres rocas del tramo %d" % index):
				_finish()
				return
		if index in [4, 9, 14]:
			if not check(await _cross_ferry(stage.moving_platforms[next_platform]), "Cruce en balsa del tramo %d" % index):
				_finish()
				return
			next_platform += 1
		if index == 8:
			var pier: float = stage.DEFINITION.secret_grove.x
			if not check(await _move_to(pier - 25) and await jump_to(pier + 205, 600)
					and await _move_to(pier + 1342) and await jump_to(pier + 1555, 600),
					"Ruta principal sobre la cubierta, sin bajar al secreto"):
				_finish()
				return
			check(not stage._secret_life_taken() and hero.health == 2, "El secreto es opcional")

	check(await _move_to(stage.DEFINITION.goal.x - 20) and stage.completed, "La puerta registra el final del recorrido")
	check(LevelProgress.new(_storage).is_completed(LEVEL), "La victoria de 2-2 se guarda por ID")
	check(CollectionProgress.new(_storage + ".collection").count("crystal", LEVEL) == 3,
		"Los tres cristales opcionales se guardan sin duplicados")
	await step(110)
	check(not main._next_level_button.visible, "2-2 termina sin ofrecer una fase todavía inexistente")
	print("COSTA 2-2: %.1f segundos simulados, con protección y un regreso extra." % stage.seconds)
	main.queue_free()
	paused = false
	await step(3)
	main = load("res://game/boot/coral_level_02.tscn").instantiate()
	main.collection_progress = CollectionProgress.new(_storage + ".secret")
	root.add_child(main)
	hero = main.player
	stage = main.stage
	check(await _check_pier_secret(), "Tótem, tres repisas, hojas, corazón único y regreso por las rocas")
	_finish()


func _board_lift(lift: ForestMovingPlatform) -> bool:
	if not await _move_to(lift.definition.start_position.x):
		return false
	for frame in 720:
		if lift.carries(hero):
			hero.controls.clear_virtual()
			return true
		if hero.is_on_floor() and lift.position.y >= lift.definition.start_position.y - 20:
			hero.controls.request_tap_jump()
		await step(1)
	return false


func _rise(lift: ForestMovingPlatform) -> bool:
	for frame in 540:
		if lift.carries(hero) and lift.position.y <= lift.definition.end_position.y + 5:
			return true
		await step(1)
	return false


func _check_practice_lift(lift: ForestMovingPlatform, x: float) -> bool:
	return await _board_lift(lift) and await _rise(lift) \
		and await jump_to(x + 1400, 265) and await _move_to(x + 1655) \
		and await jump_to(x + 1850, 190) and await _move_to(x + 1940) \
		and stage.crystals == 1 and await _move_to(x + 2220)


func _cross_high_dock(up: ForestMovingPlatform, down: ForestMovingPlatform, direction: float, region: int = -1) -> bool:
	var ridge_y: float = up.definition.end_position.y - 35
	var start: float = up.definition.start_position.x
	var end: float = down.definition.start_position.x
	if not await _board_lift(up) or not await _rise(up) or not await jump_to(start + direction * 190, ridge_y):
		return false
	if region == 7 or region == 13:
		if not await _collect_upper_crystal(region):
			return false
	if not await _move_to(end - direction * 190):
		return false
	# Aterrizaje sobre la arena al otro lado, con la cubierta disponible para volver.
	if not await _move_to(end + direction * 310):
		return false
	await step(65)
	return hero.is_on_floor() and absf(hero.position.y - 600.0) < 4.0


func _collect_upper_crystal(region: int) -> bool:
	var x: float = stage.DEFINITION.region_starts[region].x
	var before: int = stage.crystals
	if region == 7:
		return await _move_to(x + 1810) and await jump_to(x + 1940, 110) \
			and await _move_to(x + 2015) and await jump_to(x + 2170, 24) \
			and await _move_to(x + 2190) and stage.crystals == before + 1
	return await _move_to(x + 1490) and await jump_to(x + 1490, 108) \
		and await jump_to(x + 1240, 30) and await _move_to(x + 1240) and stage.crystals == before + 1 \
		and await _move_to(x + 1680)


func _cross_pools(left: float) -> bool:
	return await _move_to(left - 30) and await jump_to(left + 120, 630) \
		and await jump_to(left + 325, 568) and await jump_to(left + 555, 615) \
		and await jump_to(left + 790, 600)


func _check_pier_secret() -> bool:
	var x: float = stage.DEFINITION.secret_grove.x
	var checkpoint: Vector2 = stage.checkpoint_positions()[1]
	hero.respawn(checkpoint - Vector2(85, 0))
	await step(8)
	if not is_instance_valid(stage.secret_totem) or absf(stage.secret_totem.position.x - x) > 115:
		return false
	if not await _move_to(x + 82):
		return false
	await step(40)
	if absf(hero.position.y - 755) > 4:
		return false
	if not await jump_to(x + 320, 805) or not await _move_to(x + 405) \
			or not await jump_to(x + 590, 859) or not await _move_to(x + 950):
		return false
	await step(35)
	if not stage._secret_life_taken() or hero.maximum_health != 4 or stage.leaves < 3:
		return false
	if not await _move_to(x + 1100) or not await jump_to(x + 1180, 840) \
			or not await _move_to(x + 1240) or not await jump_to(x + 1345, 753) \
			or not await jump_to(x + 1450, 673) or not await jump_to(x + 1570, 600):
		return false
	hero.respawn(Vector2(x + 950, 930))
	await step(10)
	if not stage._secret_life_taken() or hero.maximum_health != 4 or stage.active_checkpoint_index != 1:
		return false
	var canal: ForestMovingPlatform = stage.moving_platforms[6]
	hero.respawn(canal.definition.start_position + Vector2(100, 355))
	await step(70)
	if not hero.dead:
		return false
	main._resume()
	await step(4)
	return hero.position.distance_to(stage.respawn_position) < 4 and hero.maximum_health == 4 \
		and stage._secret_life_taken() and canal.elapsed < 0.15
