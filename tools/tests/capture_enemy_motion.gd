extends SceneTree
## Dos ciclos de la malla real, sin depender del reloj de la GPU.


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1280, 720)
	var gallery: Node2D = load("res://game/features/enemies/enemy_gallery.tscn").instantiate()
	root.add_child(gallery)
	gallery.playing = false
	await process_frame
	var folder: String = "res://art/characters/motion_preview"
	DirAccess.make_dir_recursive_absolute(folder)
	for frame in 24:
		for visual: EnemyVisual in gallery.visuals:
			visual.phase = TAU * float(frame % 12) / 12.0
			visual._gait = 1.0
			visual.advance(0.0, 90.0, not visual.profile.flying)
		await process_frame
		await RenderingServer.frame_post_draw
		var picture: Image = root.get_texture().get_image()
		if picture.save_png("%s/frame_%02d.png" % [folder, frame]) != OK:
			push_error("No se pudo guardar la captura de animación")
			quit(1)
			return
	print("CAPTURA ANIMACIÓN: 24 fotogramas, dos ciclos completos, 1280 × 720")
	gallery.queue_free()
	await process_frame
	quit()
