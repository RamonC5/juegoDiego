extends "res://tools/tests/test_forest_route.gd"
## Recorrido físico completo sin teletransportes, con enemigos aislados.
## Navegación, no curación y persistencia se contrastan aparte del combate existente.


func reach_station(station: RootBridgeDefinition) -> bool:
	var floor_y: float = station.pine_position.y + 26
	if not is_equal_approx(floor_y, 260):
		return await super.reach_station(station)
	var spring: ForestSpringPad
	for candidate in stage.spring_pads:
		if absf(candidate.position.x - station.pine_position.x + 255) < 2:
			spring = candidate
			break
	if spring == null or not await ground_to(spring.position.x - 120):
		return false
	hero.controls.set_virtual_action(&"jump", true)
	var bounced: bool = false
	for frame in 220:
		var target: float = station.pine_position.x if bounced else spring.position.x
		var distance: float = target - hero.position.x
		hero.controls.set_virtual_axis(signf(distance) if absf(distance) > 5 else 0.0)
		await step(1)
		if hero.velocity.y < -950:
			bounced = true
			hero.controls.set_virtual_action(&"jump", false)
		if bounced and hero.is_on_floor() and absf(hero.position.y - floor_y) < 4:
			hero.controls.clear_virtual()
			await step(5)
			return await walk_to(station.pine_position.x)
	hero.controls.clear_virtual()
	return false


func _run() -> void:
	var storage: String = "user://forest02-%d-%d.json" % [OS.get_process_id(), Time.get_ticks_usec()]
	var progression := LevelProgress.new(storage + ".progress")
	var collection := CollectionProgress.new(storage)
	check(ForestAdventureCatalog.scene_for("world_01_level_02", progression).is_empty(), "El segundo nivel exige completar el primero")
	check(ForestAdventureCatalog.scene_for("invalid", progression).is_empty(), "Rechazar rutas desconocidas")
	check(progression.record_completion("world_01_level_01", {"seconds": 100, "keys": 3}) == OK, "Guardar victoria anterior")
	progression = LevelProgress.new(storage + ".progress")
	check(not ForestAdventureCatalog.scene_for("world_01_level_02", progression).is_empty(), "Guardado v1 desbloquea Bosque 1-2")
	var menu := ForestAdventureMenu.new()
	menu.progress = progression
	root.add_child(menu)
	await step(3)
	check(not menu.level_buttons[1].disabled and menu.level_buttons[1].has_focus(), "Segunda aventura disponible con foco")
	menu.queue_free()
	await step(2)
	main = load("res://game/boot/forest_level_02.tscn").instantiate()
	main.collection_progress = collection
	root.add_child(main)
	stage = main.stage
	hero = main.player
	main.progress = progression
	await step(8)
	check(stage.DEFINITION.level_id == "world_01_level_02" and main._hud_title.text == "1–2", "Escena e interfaz del segundo nivel")
	check(stage.checkpoint_positions().size() == 3 and stage.level_keys.size() == 3, "Tres llaves y exactamente tres faroles")
	check(not is_instance_valid(stage.secret_grove) and is_instance_valid(stage.canopy_secret), "Secreto en las copas, sin gruta subterránea")
	check(stage.spring_pads.size() == 4 and stage.enemies.size() == 66, "Contenido nuevo compuesto en el nivel real")
	check(stage.firefly != null, "El ayudante puede acompañar en la nueva aventura")
	hero.invulnerability = 100000.0
	hero.health = 2
	hero.collision_mask = 1
	hero.foot_sensor.collision_mask = 0
	for enemy in stage.enemies:
		enemy.set_physics_process(false)
		enemy.collision_layer = 0
		enemy._stomp.collision_layer = 0
		enemy._contact.monitoring = false
	var vine_index: int = 0
	for index in stage.root_gates.size():
		var gate: ForestRootGate = stage.root_gates[index]
		if not check(await throw_station(gate.definition.stations[0]), "Tramo %d: ascenso y diana real" % index):
			_finish()
			return
		if index in [2, 9, 13]:
			if not check(await cross_vine_ravine(vine_index, false), "Tramo %d: cinco lianas sin teletransporte" % index):
				_finish()
				return
			vine_index += 1
		for bridge in stage.bridges:
			if bridge.state == RootBridge.State.CLOSED and bridge.definition.pine_position.x > index * 4800 and bridge.definition.pine_position.x < gate.position.x:
				if not check(await throw_station(bridge.definition), "Tramo %d: desplegar puente" % index):
					_finish()
					return
		if not check(await throw_station(gate.definition.stations[1]), "Tramo %d: segunda diana real" % index):
			_finish()
			return
		if index in [3, 8, 14]:
			var origin_x: float = index * 4800
			if not check(await walk_to(origin_x + 3740) and await jump_to(origin_x + 3780, 290)
				and await jump_to(origin_x + 4090, 190), "Desvío intermedio de cristal, con saltos reales"):
				_finish()
				return
		if not check(gate.is_open and await ground_to(gate.position.x + 110), "Tramo %d: cruce y retorno abierto" % index):
			_finish()
			return
		if index in [3, 8, 14]:
			check(stage.collected_keys.size() == {3: 1, 8: 2, 14: 3}[index], "Llave recogida por contacto físico")
		if index in [4, 8, 12]:
			check(stage.active_checkpoint_index == {4: 0, 8: 1, 12: 2}[index] and hero.health == 2, "Contacto con farol conserva las dos vidas actuales")
	check(stage.crystals == 3 and collection.count("crystal", "world_01_level_02") == 3, "Cristales opcionales persistentes y únicos")
	check(await ground_to(stage.DEFINITION.goal.x - 20) and stage.completed and not hero.dead, "Ruta completa hasta la salida con tres llaves")
	check(progression.is_completed("world_01_level_02"), "Resultado independiente del segundo nivel")
	var reopened := CollectionProgress.new(storage)
	check(reopened.count("crystal", "world_01_level_02") == 3, "Colección conservada al reabrir")
	print("BOSQUE 1-2: %.1f segundos de ruta automática protegida; duración humana pendiente." % stage.seconds)
	_finish()

