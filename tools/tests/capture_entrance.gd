extends SceneTree
## Capturas Compatibility de las escenas nuevas con el arte final del repositorio.

const DIRECTORY := "res://art/entrance/previews"
var entrance: Control


func _initialize() -> void:
	_capture.call_deferred()


func frames(count: int = 4) -> void:
	for index in count:
		await process_frame
	await RenderingServer.frame_post_draw


func save(name: String) -> void:
	var error: Error = root.get_texture().get_image().save_png(DIRECTORY + "/" + name + ".png")
	if error != OK:
		push_error("No se pudo capturar " + name)
		quit(1)
	print("CAPTURA ", name, " ", root.size)


func _capture() -> void:
	DirAccess.make_dir_recursive_absolute(DIRECTORY)
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1280, 720)
	entrance = load("res://game/boot/entrance.tscn").instantiate()
	root.add_child(entrance)
	entrance.settings.menu_reduced_motion = false
	entrance._apply_motion()
	await frames(8)
	entrance.intro.set_process(false)
	entrance.intro.set_reduced_motion(false)
	for index in WorldCatalog.WORLDS.size():
		entrance.intro.clock = index * AdventureIntro.BEAT_SECONDS + 0.8
		entrance.intro._process(0)
		await frames()
		save("intro_world_%02d" % (index + 1))
	entrance.show_map()
	await frames()
	save("map_mobile")
	entrance._request_world("world_08")
	await frames()
	save("map_locked")
	root.size = Vector2i(1024, 768)
	root.content_scale_size = Vector2i(1280, 960)
	await frames(8)
	save("map_tablet")
	entrance.show_intro()
	entrance.settings.menu_reduced_motion = true
	entrance._apply_motion()
	await frames()
	save("intro_tablet_reduced_motion")
	entrance.queue_free()
	await frames()
	quit()
