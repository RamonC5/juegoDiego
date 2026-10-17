extends SceneTree
## Evidencia visual del agarre y las transiciones, con la escena y el raster reales.

var main: Node2D


func _initialize() -> void:
	_capture.call_deferred()


func frames(count: int) -> void:
	for frame in count:
		await process_frame
	await RenderingServer.frame_post_draw


func save(name: String) -> void:
	var path: String = "res://art/characters/diego/movement_preview/" + name + ".png"
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	if root.get_texture().get_image().save_png(path) != OK:
		push_error("No se pudo guardar " + path)
		quit(1)
	print("CAPTURA MOVIMIENTO ", path)


func _capture() -> void:
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1280, 720)
	main = preload("res://game/boot/main.tscn").instantiate()
	root.add_child(main)
	await frames(12)
	for enemy in main.stage.enemies:
		enemy.set_physics_process(false)
		enemy.collision_layer = 0
		enemy._contact.monitoring = false
		enemy._stomp.collision_layer = 0
	var hero: DiegoPlayer = main.player
	var vine: ForestSwingingVine = main.stage.vine_crossings[0].vines[1]
	hero.respawn(vine.grip_global_position() - DiegoPlayer.VINE_HAND_OFFSET)
	hero._try_grab_swinging_vine()
	await frames(18)
	save("vine_hang_mobile")
	# Acercar la cámara permite revisar dedos, cuerda, espejo y raíz visual.
	main.camera.zoom = Vector2(2, 2)
	await frames(8)
	save("vine_hang_detail")
	hero.controls.set_virtual_axis(-1.0)
	await frames(12)
	save("vine_hang_mirrored")
	hero.controls.set_virtual_axis(1.0)
	hero.controls.request_tap_jump()
	await frames(2)
	save("vine_release")
	hero.controls.request_tap_jump()
	await frames(2)
	save("double_jump")
	main.camera.zoom = Vector2.ONE
	root.size = Vector2i(1024, 768)
	root.content_scale_size = Vector2i(1280, 960)
	hero.respawn(vine.grip_global_position() - DiegoPlayer.VINE_HAND_OFFSET)
	hero._try_grab_swinging_vine()
	await frames(12)
	save("vine_hang_tablet")
	main.queue_free()
	await frames(2)
	await preload("res://tools/tests/audio_cleanup.gd").flush(self)
	quit()
