extends SceneTree
## Evidencia gráfica: composición de recursos reales en el renderizador del juego.

var _main: Node2D
const DESTINATION: String = "res://art/objects/"


func _initialize() -> void:
	_capture.call_deferred()


func _frames(count: int) -> void:
	for _frame in count:
		await process_frame
	await RenderingServer.frame_post_draw


func _save(name: String) -> void:
	var result: Error = root.get_texture().get_image().save_png(DESTINATION + name + ".png")
	if result != OK:
		push_error("No se pudo guardar " + name)
		quit(1)
	print("Captura: ", name)


func _label(parent: Node, text: String, at: Vector2, width: float, font_size: int, color: Color) -> Label:
	var result := Label.new()
	result.text = text
	result.position = at
	result.size.x = width
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", color)
	parent.add_child(result)
	return result


func _capture() -> void:
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1280, 720)
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	var board := Node2D.new()
	root.add_child(board)
	var background := ColorRect.new()
	background.size = Vector2(1280, 720)
	background.color = Color("112c32")
	board.add_child(background)
	_label(board, "SALTO HEROES · OBJETOS ARROJADIZOS", Vector2(30, 16), 1220, 32, Color("fff1ce"))
	_label(board, "Seis propuestas originales · Sprites raster 2D · Android y Windows", Vector2(30, 62), 1220, 20, Color("b5d3ca"))
	for index in ThrowableCatalog.DEFINITIONS.size():
		var definition: ThrowableDefinition = ThrowableCatalog.DEFINITIONS[index]
		var origin := Vector2(30 + (index % 3) * 412, 108 + (index / 3) * 294)
		var light: bool = index % 2 == 0
		var text_color: Color = Color("16363d") if light else Color("fff1ce")
		var card := Panel.new()
		card.position = origin
		card.size = Vector2(396, 276)
		var style := StyleBoxFlat.new()
		style.bg_color = Color("dce9dd") if light else Color("244a50")
		style.set_corner_radius_all(14)
		card.add_theme_stylebox_override("panel", style)
		board.add_child(card)
		_label(board, definition.display_name, origin + Vector2(16, 12), 366, 24, text_color)
		var sprite := Sprite2D.new()
		sprite.texture = definition.make_sprite_texture()
		sprite.position = origin + Vector2(198, 132)
		var material := ShaderMaterial.new()
		material.shader = ThrowableObject.ART_SHADER
		sprite.material = material
		var maximum: float = maxf(sprite.texture.get_width(), sprite.texture.get_height())
		sprite.scale = Vector2.ONE * (158.0 / maximum)
		board.add_child(sprite)
		_label(board, definition.description, origin + Vector2(16, 220), 364, 18, text_color)
	await _frames(6)
	_save("preview_catalog")
	board.queue_free()
	await _frames(2)
	_main = load("res://game/boot/main.tscn").instantiate()
	main.collection_progress = CollectionProgress.new("user://collection-capture_throwables-%d-%d.json" % [OS.get_process_id(), Time.get_ticks_usec()])
	root.add_child(_main)
	_main.settings.show_gesture_hints = false
	_main._apply_settings()
	_main.touch.refresh()
	await _frames(35)
	_save("preview_gameplay")
	var world: Node = _main.get_node("PracticeStage")
	var first: ThrowableObject
	for child in world.get_children():
		if child is ThrowableObject:
			first = child
			break
	_main.player.position = Vector2(240, 500)
	first.pick_up(_main.player.hand)
	_main.player.held_object = first
	await _frames(10)
	_save("preview_carry")
	root.size = Vector2i(1024, 768)
	await _frames(6)
	_save("preview_tablet")
	_main.queue_free()
	await _frames(2)
	quit()

