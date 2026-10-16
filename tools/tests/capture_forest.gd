extends SceneTree
## Capturas con Compatibility real, sin sustituir la escena por un montaje.

var main: Node2D


func _initialize() -> void:
	_capture.call_deferred()


func _frames(count: int) -> void:
	for _index in count:
		await process_frame
	await RenderingServer.frame_post_draw


func _save(name: String) -> void:
	DirAccess.make_dir_recursive_absolute("res://art/levels/bosque_esmeralda")
	var result: Error = root.get_texture().get_image().save_png("res://art/levels/bosque_esmeralda/" + name + ".png")
	if result != OK:
		push_error("No se pudo guardar " + name)
		quit(1)
	print("CAPTURA ", name, " ", root.size)


func _capture() -> void:
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1280, 720)
	main = load("res://game/boot/main.tscn").instantiate()
	root.add_child(main)
	main.settings.show_touch = true
	main.settings.show_gesture_hints = true
	main._apply_settings()
	main.touch.refresh()
	await _frames(60)
	_save("preview_start")
	main.touch._guide_time = 0.0
	main.touch._update_guides()
	main.player.respawn(Vector2(1110, 435))
	await _frames(4)
	_save("preview_route")
	main.player.respawn(Vector2(4180, 600))
	await _frames(8)
	_save("preview_checkpoint")
	main._open_menu("Pausa y controles")
	await _frames(3)
	_save("preview_pause")
	main._resume()
	root.size = Vector2i(1024, 768)
	root.content_scale_size = Vector2i(1280, 960)
	main.player.respawn(Vector2(7460, 515))
	await _frames(5)
	_save("preview_tablet")
	root.size = Vector2i(1600, 720)
	root.content_scale_size = Vector2i(1600, 720)
	main.player.respawn(Vector2(2600, 435))
	await _frames(5)
	_save("preview_mobile_wide")
	main.queue_free()
	await _frames(2)
	quit()
