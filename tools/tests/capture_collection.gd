extends SceneTree
## Capturas reales de vestuario, materiales y aleteo con Compatibility.

var main: Node2D
var directory: String = "res://art/characters/luci"
var storage: String = "user://collection-capture-%d.json" % OS.get_process_id()


func _initialize() -> void:
	_capture.call_deferred()


func frames(count: int = 4) -> void:
	for index in count:
		await process_frame
	await RenderingServer.frame_post_draw


func save(name: String) -> void:
	var error: Error = root.get_texture().get_image().save_png(directory + "/" + name + ".png")
	if error != OK:
		push_error("No se pudo guardar " + name)
		quit(1)
	print("CAPTURA ", name, " ", root.size)


func _capture() -> void:
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1280, 720)
	DirAccess.make_dir_recursive_absolute(directory)
	main = preload("res://game/boot/main.tscn").instantiate()
	main.collection_progress = CollectionProgress.new(storage)
	root.add_child(main)
	await frames(8)
	main._open_wardrobe()
	await frames()
	save("preview_wardrobe_locked")
	main._close_wardrobe()
	main._resume()
	for item in main.stage.collectibles:
		item._on_body_entered(main.player)
	for fragment in main.stage.fragments:
		fragment._on_body_entered(main.player)
	main.player.respawn(Vector2(650, 600))
	main.player.set_physics_process(false)
	main.player.sprite.stop()
	main._reward_toast.hide()
	main._toast_seconds = 0.0
	main._reward_queue.clear()
	for id in ["original", "autumn_scarf", "fern_vest", "forest_explorer", "golden_forest"]:
		main.collection_progress.equip(id)
		await frames(8)
		save("preview_outfit_" + id)
	main._open_wardrobe()
	main._collection_menu._select("fern_vest")
	await frames()
	save("preview_wardrobe_mobile")
	root.size = Vector2i(960, 540)
	root.content_scale_size = Vector2i.ZERO
	await frames(8)
	save("preview_wardrobe_compact")
	root.size = Vector2i(1024, 768)
	root.content_scale_size = Vector2i(1280, 960)
	await frames(8)
	save("preview_wardrobe_tablet")
	main.queue_free()
	paused = false
	await frames()
	for suffix in ["", ".tmp", ".bak"]:
		DirAccess.remove_absolute(storage + suffix)
	await preload("res://tools/tests/audio_cleanup.gd").flush(self)
	quit()

