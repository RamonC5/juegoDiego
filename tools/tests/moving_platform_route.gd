extends RefCounted
## Acciones reales compartidas por las suites; no cambia posiciones, velocidad ni ciclos.


static func step(tree: SceneTree, count: int) -> void:
	for _frame in count:
		await tree.physics_frame
		await tree.process_frame


static func walk_to(main: Node2D, x: float, limit: int = 240) -> bool:
	var hero: DiegoPlayer = main.player
	for _frame in limit:
		if hero.dead:
			return false
		var distance: float = x - hero.position.x
		if absf(distance) < 5.0:
			hero.controls.clear_virtual()
			await step(main.get_tree(), 8)
			return true
		hero.controls.set_virtual_axis(signf(distance))
		await step(main.get_tree(), 1)
	hero.controls.clear_virtual()
	return false


static func jump_to(main: Node2D, x: float) -> bool:
	var hero: DiegoPlayer = main.player
	hero.controls.set_virtual_action(&"jump", false)
	await step(main.get_tree(), 2)
	hero.controls.set_virtual_action(&"jump", true)
	for frame in 110:
		if hero.dead:
			return false
		var distance: float = x - hero.position.x
		hero.controls.set_virtual_axis(signf(distance) if absf(distance) > 5.0 else 0.0)
		await step(main.get_tree(), 1)
		if frame > 20 and hero.is_on_floor() and absf(x - hero.position.x) < 10.0:
			hero.controls.clear_virtual()
			await step(main.get_tree(), 5)
			return true
	hero.controls.clear_virtual()
	return false


static func reach_third_key(main: Node2D) -> bool:
	var hero: DiegoPlayer = main.player
	var stage: ForestStage = main.stage
	var lift: ForestMovingPlatform = stage.moving_platforms[1]
	hero.controls.clear_virtual()
	hero.controls.automatic_run = false
	hero.controls.full_jump = true
	# Llegar desde la izquierda, sobre tierra firme, y observar una vuelta completa si hace falta.
	if not await walk_to(main, 6310.0):
		return false
	var ready: bool = false
	for _frame in 600:
		if lift.elapsed < 0.25 and lift.position.y > 544.0:
			ready = true
			break
		await step(main.get_tree(), 1)
	if not ready or not await jump_to(main, 6500.0) or not lift.carries(hero):
		print("DIAGNÓSTICO EMBARQUE: ", hero.position, " tronco=", lift.position)
		return false
	var arrived: bool = false
	for _frame in 360:
		if lift.position.y < 296.0 and lift.carries(hero):
			arrived = true
			break
		await step(main.get_tree(), 1)
	if not arrived or not await walk_to(main, 6545.0, 90):
		return false
	if not await jump_to(main, 6680.0):
		print("DIAGNÓSTICO REPISA: ", hero.position, " tronco=", lift.position)
		return false
	if not await walk_to(main, stage.level_keys[2].position.x):
		return false
	return stage.level_keys[2].taken and hero.position.y < 270.0 and not hero.dead
