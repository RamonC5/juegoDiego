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
	main.player.respawn(Vector2(860, 600))
	await _frames(10)
	_save("preview_enemy_intro")
	main.player.respawn(Vector2(7040, 600))
	await _frames(10)
	_save("preview_enemy_finish")
	main.player.respawn(main.stage.DEFINITION.spawn)
	await _frames(10)
	main.player.controls.set_virtual_action(&"crouch", true)
	await _frames(10)
	_save("preview_crouch")
	main.player.controls.set_virtual_action(&"crouch", false)
	await _frames(3)
	main.touch._guide_time = 0.0
	main.touch._update_guides()
	main.player.respawn(Vector2(1110, 435))
	await _frames(4)
	_save("preview_route")
	main.player.respawn(Vector2(2540, 600))
	await _frames(45)
	_save("preview_bridge_practice_closed")
	main.stage.throw_targets[0].break_apart()
	await _frames(8)
	_save("preview_target_breaking")
	await _frames(50)
	_save("preview_target_broken")
	main.stage.throw_targets[0].reset_to_intact()
	main.player.respawn(Vector2(3080, 820))
	await _frames(20)
	_save("preview_bridge_recovery")
	main.player.respawn(Vector2(3430, 600))
	await _frames(45)
	_save("preview_bridge_main_closed")
	_save("preview_checkpoint")
	# Capturas de la ampliación antes de resolver los pasos para el resto de vistas.
	main.player.respawn(Vector2(7480, 600))
	await _frames(45)
	_save("preview_roots_two_marks")
	main.player.respawn(Vector2(9950, 260))
	await _frames(30)
	_save("preview_terraces_guard")
	main.player.respawn(Vector2(8200 + 2 * 4000 + 1350, 600))
	await _frames(35)
	_save("preview_canopy_lift")
	main.player.respawn(Vector2(8200 + 5 * 4000 + 3750, 600))
	await _frames(20)
	_save("preview_first_key_route")
	# Barranco de lianas: capturas reales del nuevo gesto y los discos.
	# Se retira la referencia histórica a moving_platforms[6] (solo hay cinco).
	main.player.respawn(Vector2(25980, 445))
	await _frames(24)
	_save("preview_vine_climb")
	main.player.respawn(Vector2(26760, 340))
	await _frames(24)
	_save("preview_vine_targets")
	main.player.respawn(Vector2(3430, 600))
	for target in main.stage.throw_targets:
		main.stage._on_mechanism_activated(target.definition.mechanism_id)
		target.restore_activated()
	await create_timer(0.8, false).timeout
	await _frames(45)
	_save("preview_bridge_main_open")
	main.player.respawn(Vector2(3960, 600))
	await _frames(15)
	_save("preview_bridge_crossing")
	main.player.respawn(Vector2(5500, 600))
	main.stage.moving_platforms[0].reset_cycle()
	await _frames(20)
	_save("preview_moving_practice")
	main.stage.moving_platforms[1].reset_cycle()
	main.player.respawn(Vector2(6460, 515))
	await _frames(210)
	_save("preview_moving_lift_mobile")
	main._open_menu("Pausa y controles")
	await _frames(3)
	_save("preview_pause")
	main._resume()
	root.size = Vector2i(1024, 768)
	root.content_scale_size = Vector2i(1280, 960)
	main.player.respawn(Vector2(7460, 515))
	await _frames(5)
	_save("preview_tablet")
	main.player.respawn(Vector2(3430, 600))
	await _frames(45)
	main.stage._on_bridge_opened(&"puente_diana_principal")
	_save("preview_bridge_tablet")
	main.player.respawn(Vector2(6760, 260))
	await _frames(15)
	_save("preview_moving_key_tablet")
	main.player.respawn(Vector2(7460, 515))
	await _frames(10)
	main.player.controls.set_virtual_action(&"crouch", true)
	await _frames(10)
	_save("preview_crouch_tablet")
	main.player.controls.set_virtual_action(&"crouch", false)
	await _frames(3)
	root.size = Vector2i(1600, 720)
	root.content_scale_size = Vector2i(1600, 720)
	main.player.respawn(Vector2(2600, 435))
	await _frames(5)
	_save("preview_mobile_wide")
	main.player.respawn(Vector2(6460, 600))
	await _frames(20)
	_save("preview_moving_wide")
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1280, 720)
	for enemy in main.stage.enemies:
		enemy.set_physics_process(false)
	main.player.respawn(Vector2(6400, 515))
	await _frames(5)
	_save("preview_keys_platform")
	main.player.respawn(main.stage.DEFINITION.goal - Vector2(170, 0))
	await _frames(5)
	_save("preview_keys_locked")
	for key in main.stage.level_keys:
		key._on_body_entered(main.player)
	await _frames(40)
	_save("preview_keys_open")
	main.queue_free()
	await _frames(2)
	await preload("res://tools/tests/audio_cleanup.gd").flush(self)
	quit()




