extends SceneTree
## Revisión con renderizador real. Ejecutar en una sesión gráfica o Xvfb.

var _main: Node2D


func _initialize() -> void:
	_capture.call_deferred()


func _frames(count: int) -> void:
	for _index in count:
		await process_frame
	await RenderingServer.frame_post_draw


func _save(name: String) -> void:
	var image: Image = root.get_texture().get_image()
	var path: String = "res://art/characters/diego/" + name + ".png"
	if image.save_png(path) != OK:
		push_error("No se pudo guardar " + path)
		quit(1)
	print("Captura: ", name, " ", image.get_size())


func _capture() -> void:
	root.size = Vector2i(1280, 720)
	_main = load("res://game/boot/main.tscn").instantiate()
	root.add_child(_main)
	await _frames(12)
	_main.settings.left_handed = false
	_main.settings.gesture_scale = 1.0
	_main.settings.automatic_run = true
	_main.settings.full_jump = false
	_main.settings.show_touch = true
	_main.settings.show_gesture_hints = true
	_main._apply_settings()
	_main.touch.refresh()
	await _frames(3)
	_save("preview_gameplay")
	_touch(0, Vector2(220, 540), true)
	_drag(0, Vector2(300, 540))
	_touch(1, Vector2(1010, 530), true)
	_drag(1, Vector2(1010, 465))
	await _frames(2)
	_save("preview_gestures")
	_main.touch.release_all()
	_main._open_menu("Pausa y controles")
	await _frames(3)
	_save("preview_controls")
	_main._resume()
	root.size = Vector2i(1024, 768)
	await _frames(5)
	_save("preview_tablet")
	_main.touch._guide_time = 0.0
	_main.touch._update_guides()
	await _frames(2)
	_save("preview_clean")
	_main.queue_free()
	await _frames(2)
	await _animation_board()
	quit()


func _touch(index: int, point: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = point
	event.pressed = pressed
	root.push_input(event, true)


func _drag(index: int, point: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = point
	root.push_input(event, true)


func _animation_board() -> void:
	root.size = Vector2i(1280, 720)
	root.canvas_transform = Transform2D.IDENTITY
	var board := Node2D.new()
	root.add_child(board)
	var states: Array = [
		["idle", "Reposo", 0], ["walk", "Caminar", 1], ["run", "Correr", 2],
		["jump_up", "Subida", 1], ["fall", "Caída", 0], ["land", "Aterrizaje", 0],
		["carry_idle", "Sostener", 0], ["carry_run", "Transportar", 1],
		["grab", "Recoger", 1], ["throw", "Lanzar", 2], ["hurt", "Daño", 1],
		["defeated", "Derrota", 3], ["victory", "Victoria", 2],
	]
	for index in states.size():
		var column: int = index % 5
		var row: int = index / 5
		var dark: bool = index % 2 == 0
		var card := ColorRect.new()
		card.position = Vector2(12+column*256, 25+row*228)
		card.size = Vector2(232, 210)
		card.color = Color("1b3941") if dark else Color("e0e9d9")
		board.add_child(card)
		var label := Label.new()
		label.text = states[index][1]
		label.position = card.position + Vector2(12, 8)
		label.add_theme_font_size_override("font_size", 22)
		label.add_theme_color_override("font_color", Color("f4f5ed") if dark else Color("183137"))
		board.add_child(label)
		var hero: DiegoPlayer = load("res://game/features/player/diego.tscn").instantiate()
		board.add_child(hero)
		hero.set_physics_process(false)
		hero.position = card.position + Vector2(116, 180)
		hero.sprite.stop()
		hero.sprite.animation = StringName(states[index][0])
		hero.sprite.frame = states[index][2]
		hero.sprite.scale = Vector2.ONE * float(hero._visual_scales[states[index][0]])
	await _frames(4)
	_save("preview_animations")
	board.queue_free()
	await _frames(2)
