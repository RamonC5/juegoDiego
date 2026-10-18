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
		{"position": Vector2(11080, 600), "name": "vines"}]:
		main.player.respawn(frame.position)
		await _frames(10)
		_save("preview_level02_" + frame.name)
	main.queue_free()
	await process_frame
	await preload("res://tools/tests/audio_cleanup.gd").flush(self)
	quit(0)
