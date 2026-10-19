extends "res://tools/tests/capture_forest.gd"
## Capturas del selector y Bosque 1-2 con el renderizador Compatibility real.


func _capture() -> void:
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1280, 720)
	var menu := ForestAdventureMenu.new()
	menu.progress = LevelProgress.new("user://capture-forest02-progress.json")
	menu.progress.levels = {"world_01_level_01": {"completed": true}}
	root.add_child(menu)
	await _frames(5)
	_save("preview_level02_selection")
	root.size = Vector2i(960, 540)
	root.content_scale_size = Vector2i(960, 540)
	await _frames(5)
	_save("preview_level02_selection_compact")
	menu.queue_free()
	menu = ForestAdventureMenu.new()
	menu.progress = LevelProgress.new("user://capture-forest02-new-profile.json")
	menu.progress.levels = {}
	root.add_child(menu)
	await _frames(3)
	_save("preview_level02_selection_locked")
	menu.queue_free()
	await _frames(3)
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1280, 720)
	main = load("res://game/boot/forest_level_02.tscn").instantiate()
	main.collection_progress = CollectionProgress.new("user://capture-forest02-%d.json" % Time.get_ticks_usec())
	root.add_child(main)
	main.player.invulnerability = 10000
	for frame in [{"position": Vector2(900, 600), "name": "spring"},
		{"position": Vector2(1350, 260), "name": "canopy"},
		{"position": Vector2(11080, 600), "name": "vines"},
		{"position": Vector2(19560, 600), "name": "secret_entry"},
		{"position": Vector2(20030, -60), "name": "secret_crowns"},
		{"position": Vector2(22070, -30), "name": "secret_life"},
		{"position": Vector2(22840, 345), "name": "secret_descent"}]:
		main.player.respawn(frame.position)
		await _frames(10)
		_save("preview_level02_" + frame.name)
	main.stage.canopy_secret.vine.reset_cycle()
	main.player.respawn(main.stage.canopy_secret.position)
	main.player.controls.set_virtual_action(&"jump", true)
	for tick in 12:
		await physics_frame
		await process_frame
	if main.player.attached_vine != main.stage.canopy_secret.vine:
		push_error("La captura de trepa exige un agarre físico real a la liana de entrada")
		quit(1)
		return
	main.player.controls.clear_virtual()
	main.player.controls.set_virtual_action(&"climb_up", true)
	for tick in 260:
		await physics_frame
		await process_frame
	main.player.controls.clear_virtual()
	await _frames(2)
	_save("preview_level02_secret_climb")
	main.queue_free()
	await process_frame
	await preload("res://tools/tests/audio_cleanup.gd").flush(self)
	quit(0)

