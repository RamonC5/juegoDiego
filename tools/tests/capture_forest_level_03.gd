extends "res://tools/tests/capture_forest.gd"


func _capture() -> void:
	root.size = Vector2i(1280, 720)
	root.content_scale_size = root.size
	main = load("res://game/boot/forest_level_03.tscn").instantiate()
	main.collection_progress = CollectionProgress.new("user://capture-forest03-%d.json" % Time.get_ticks_usec())
	root.add_child(main)
	main.player.invulnerability = 10000
	await _frames(20)
	_save("preview_forest03_start")
	main.player.respawn(Vector2(19000, 600))
	await _frames(10)
	_save("preview_forest03_key")
	main.player.respawn(Vector2(42600, 85))
	await _frames(3)
	_save("preview_forest03_crystal")
	main.queue_free()
	await _frames(3)
	main = load("res://game/boot/forest_boss.tscn").instantiate()
	main.collection_progress = CollectionProgress.new("user://capture-nudor-%d.json" % Time.get_ticks_usec())
	root.add_child(main)
	main.player.invulnerability = 10000
	await _frames(25)
	_save("preview_nudor_intro")
	var boss: NudorBoss = main.stage.boss
	while boss.state != NudorBoss.State.SLAM_WARNING:
		await _frames(1)
	await _frames(55)
	_save("preview_nudor_slam_warning")
	while boss.state != NudorBoss.State.OPEN:
		await _frames(1)
	await _frames(22)
	_save("preview_nudor_open")
	while boss.state != NudorBoss.State.SWEEP:
		await _frames(1)
	await _frames(25)
	_save("preview_nudor_sweep")
	main._toggle_pause()
	await _frames(3)
	_save("preview_nudor_pause")
	main._resume()
	root.size = Vector2i(960, 540)
	root.content_scale_size = root.size
	await _frames(10)
	_save("preview_nudor_mobile")
	main.queue_free()
	await _frames(3)
	var menu := ForestAdventureMenu.new()
	menu.progress = LevelProgress.new("user://capture-forest03-menu-%d.json" % Time.get_ticks_usec())
	for id in ["world_01_level_01", "world_01_level_02", "world_01_level_03"]:
		menu.progress.record_completion(id, {})
	root.add_child(menu)
	await _frames(5)
	_save("preview_forest03_selector")
	menu.queue_free()
	await _frames(3)
	await preload("res://tools/tests/audio_cleanup.gd").flush(self)
	quit(0)
