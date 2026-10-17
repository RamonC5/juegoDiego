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
	var first_pose: Image
	for frame in 24:
		for visual: EnemyVisual in gallery.visuals:
			visual.phase = TAU * float(frame % 12) / 12.0
			visual._gait = 1.0
			visual.advance(0.0, 90.0, not visual.profile.flying)
			# Impedir falsos positivos por balanceo del cuerpo.
			visual.position = Vector2.ZERO
			visual.rotation = 0.0
		await process_frame
		await RenderingServer.frame_post_draw
		var picture: Image = root.get_texture().get_image()
		if frame == 0:
			first_pose = picture.duplicate()
		if frame == 3:
			for index in gallery.visuals.size():
				var visual: EnemyVisual = gallery.visuals[index]
				var location: Vector2 = visual.get_parent().position
				var count: int = 0
				for py in range(maxi(0, int(location.y) - 180), mini(picture.get_height(), int(location.y)), 2):
					for px in range(maxi(0, int(location.x) - 110), mini(picture.get_width(), int(location.x) + 110), 2):
						var before: Color = first_pose.get_pixel(px, py)
						var after: Color = picture.get_pixel(px, py)
						if absf(before.r - after.r) + absf(before.g - after.g) + absf(before.b - after.b) > 0.22:
							count += 1
				if count < 10:
					push_error("%s no mueve suficientes píxeles en Compatibility: %d" % [EnemyMotionProfiles.IDS[index], count])
					quit(1)
					return
				print("MOVIMIENTO RASTER %s píxeles cambiados=%d" % [EnemyMotionProfiles.IDS[index], count])
		if picture.save_png("%s/frame_%02d.png" % [folder, frame]) != OK:
			push_error("No se pudo guardar la captura de animación")
			quit(1)
			return
	print("CAPTURA ANIMACIÓN: 24 fotogramas, dos ciclos completos, 1280 × 720")
	gallery.queue_free()
	await process_frame
	quit()
