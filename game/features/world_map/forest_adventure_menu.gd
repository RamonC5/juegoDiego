class_name ForestAdventureMenu
extends Control
## Selección táctil, teclado y mando; solo carga el nivel tras elegirlo.

var progress: LevelProgress
var level_buttons: Array[Button] = []
var status: Label
var _panel: PanelContainer
var _loading: bool = false


func _ready() -> void:
	if progress == null:
		progress = LevelProgress.new()
	var palette := Theme.new()
	palette.default_font_size = 23
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("193d3e")
	normal.set_corner_radius_all(14)
	normal.set_border_width_all(2)
	normal.border_color = Color("699489")
	palette.set_stylebox("normal", "Button", normal)
	var focus: StyleBoxFlat = normal.duplicate()
	focus.set_border_width_all(4)
	focus.border_color = Color("ffe2a1")
	palette.set_stylebox("focus", "Button", focus)
	palette.set_stylebox("hover", "Button", focus)
	theme = palette
	var background := ColorRect.new()
	background.color = Color("0a2933")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	_panel = PanelContainer.new()
	var style: StyleBoxFlat = normal.duplicate()
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	_panel.add_child(column)
	var title := Label.new()
	title.text = "Bosque Esmeralda"
	title.add_theme_font_size_override("font_size", 32)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	for level in ForestAdventureCatalog.LEVELS:
		var available: bool = not ForestAdventureCatalog.scene_for(level.id, progress).is_empty()
		var state: String = "Completado · Rejugar" if progress.is_completed(level.id) else "Disponible"
		if not available:
			state = "Bloqueado · Completa Bosque 1–1"
		var button := Button.new()
		button.text = "%s\n%s\n%s" % [level.name, level.detail, state]
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size = Vector2(0, 108)
		button.disabled = not available
		button.accessibility_name = "%s. %s" % [level.name, state]
		button.accessibility_description = level.detail
		button.pressed.connect(_request_level.bind(level.id))
		column.add_child(button)
		level_buttons.append(button)
	status = Label.new()
	status.text = "Tres llaves para salir · Cristales y hojas opcionales"
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(status)
	var back := Button.new()
	back.text = "Volver al mapa"
	back.custom_minimum_size.y = 54
	back.pressed.connect(_return_to_map)
	column.add_child(back)
	get_viewport().size_changed.connect(_layout)
	_layout()
	level_buttons[1 if progress.is_completed("world_01_level_01") else 0].grab_focus()
	_log_ready.call_deferred()


func _layout() -> void:
	var safe := Rect2(Vector2.ZERO, get_viewport_rect().size)
	var physical: Rect2i = DisplayServer.get_display_safe_area()
	if OS.has_feature("android") and physical.has_area():
		safe = get_viewport().get_screen_transform().affine_inverse() * Rect2(physical)
	var width: float = minf(760, safe.size.x - 40)
	_panel.position = safe.position + Vector2((safe.size.x - width) / 2.0, 20)
	_panel.size = Vector2(width, safe.size.y - 40)


func _log_ready() -> void:
	var point: Vector2 = level_buttons[0].get_global_rect().get_center() / get_viewport_rect().size
	print("SUPER_DIEGO_LEVELS_READY first=%.4f,%.4f" % [point.x, point.y])


func _request_level(id: String) -> void:
	if _loading:
		return
	var target: String = ForestAdventureCatalog.scene_for(id, progress)
	if target.is_empty():
		status.text = "Completa Bosque 1–1 para abrir la siguiente aventura."
		return
	_loading = true
	status.text = "Preparando aventura…"
	await get_tree().process_frame
	var error: Error = get_tree().change_scene_to_file(target)
	if error != OK:
		_loading = false
		status.text = "No se pudo abrir el nivel. Vuelve a intentarlo."


func _return_to_map() -> void:
	if _loading:
		return
	var entrance: Control = load("res://game/boot/entrance.tscn").instantiate()
	entrance.set("initial_page", &"map")
	get_tree().root.add_child(entrance)
	get_tree().current_scene = entrance
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") or event.is_action_pressed(&"pause"):
		_return_to_map()
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_return_to_map()
