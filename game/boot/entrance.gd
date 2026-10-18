extends Control
## Entrada -> mapa -> bosque. El nivel no se carga hasta una selección válida.

var initial_page: StringName = &"intro"
var page: StringName = &"intro"
var settings: ControlSettings
var intro: AdventureIntro
var world_map: AdventureWorldMap
var play_button: Button
var back_button: Button
var motion_button: Button
var _replay_button: Button
var _title: Label
var _hero_title: SuperheroTitle
var _eyebrow: Label
var _subtitle: Label
var _status: Label
var _loading: bool = false
var _safe := Rect2()


func _ready() -> void:
	settings = ControlSettings.new()
	add_child(settings)
	_build_theme()
	var background := ColorRect.new()
	background.color = Color("0a2933")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	intro = AdventureIntro.new()
	intro.accessibility_name = "Diego explora ocho mundos: corre, salta y se balancea en una liana. Puedes ir al mapa en cualquier momento."
	add_child(intro)
	world_map = AdventureWorldMap.new()
	add_child(world_map)
	world_map.world_requested.connect(_request_world)
	_title = _label("", 88, Color("fff2cd"))
	_hero_title = SuperheroTitle.new()
	add_child(_hero_title)
	_eyebrow = _label("OCHO MUNDOS · UNA GRAN AVENTURA", 19, Color("e4b968"))
	_subtitle = _label("", 24, Color("c4dcd9"))
	_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status = _label("", 19, Color("e0e6d9"))
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	play_button = _button("Jugar ahora", show_map)
	play_button.name = "PlayNow"
	play_button.accessibility_name = "Jugar ahora. Abrir mapa de mundos"
	play_button.add_theme_font_size_override("font_size", 30)
	var primary := _style(Color("edbb60"), Color("ffe3a3"))
	play_button.add_theme_stylebox_override("normal", primary)
	play_button.add_theme_color_override("font_color", Color("173d37"))
	play_button.add_theme_color_override("font_hover_color", Color("173d37"))
	play_button.add_theme_color_override("font_focus_color", Color("173d37"))
	play_button.add_theme_color_override("font_pressed_color", Color("173d37"))
	play_button.add_theme_stylebox_override("hover", _style(Color("ffdb8c"), Color("fff1c7")))
	back_button = _button("‹  Inicio", show_intro)
	back_button.name = "BackToIntro"
	motion_button = _button("", _toggle_motion)
	motion_button.name = "ReducedMotion"
	_replay_button = _button("Repetir aventuras", _restart_intro)
	_replay_button.accessibility_name = "Repetir la animación de aventuras"
	get_viewport().size_changed.connect(_layout)
	_apply_motion()
	if initial_page == &"map":
		show_map()
	else:
		show_intro()


func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	add_child(label)
	return label


func _button(text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(80, 52)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pressed.connect(action)
	add_child(button)
	return button


func _style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.set_corner_radius_all(14)
	style.set_border_width_all(2)
	style.border_color = border
	style.content_margin_left = 12
	style.content_margin_right = 12
	return style


func _build_theme() -> void:
	var palette := Theme.new()
	palette.default_font_size = 19
	palette.set_stylebox("normal", "Button", _style(Color(0.025, 0.12, 0.14, 0.96), Color("638d88")))
	palette.set_stylebox("hover", "Button", _style(Color("245456"), Color("ffe3a3")))
	palette.set_stylebox("pressed", "Button", _style(Color("346563"), Color("fff2cd")))
	var focus := _style(Color(0, 0, 0, 0), Color("ffe49a"))
	focus.set_border_width_all(4)
	palette.set_stylebox("focus", "Button", focus)
	palette.set_color("font_color", "Button", Color("fff2cd"))
	palette.set_color("font_hover_color", "Button", Color("ffffff"))
	theme = palette


func show_intro() -> void:
	if _loading:
		return
	page = &"intro"
	intro.show()
	_title.hide()
	_hero_title.show()
	world_map.hide()
	play_button.show()
	back_button.hide()
	_replay_button.visible = not settings.menu_reduced_motion
	_hero_title.restart()
	_subtitle.text = "Saltos, secretos y un montón\nde aventuras por descubrir."
	_eyebrow.text = "OCHO MUNDOS · UNA GRAN AVENTURA"
	_status.text = ""
	_layout()
	play_button.grab_focus()
	_log_intro_ready.call_deferred()


func show_map() -> void:
	if _loading:
		return
	page = &"map"
	intro.hide()
	_title.show()
	_hero_title.hide()
	world_map.show()
	play_button.hide()
	back_button.show()
	_replay_button.hide()
	_title.text = "Elige tu mundo"
	_eyebrow.text = "LAS AVENTURAS DE DIEGO"
	_subtitle.text = ""
	_status.text = "Bosque Esmeralda disponible · Los otros siete mundos están bloqueados."
	_layout()
	world_map.world_buttons[0].grab_focus()
	_log_map_ready.call_deferred()


func _log_intro_ready() -> void:
	var point: Vector2 = play_button.get_global_rect().get_center() / get_viewport_rect().size
	print("SUPER_DIEGO_ENTRANCE_READY play=%.4f,%.4f" % [point.x, point.y])


func _log_map_ready() -> void:
	var point: Vector2 = world_map.world_buttons[0].get_global_rect().get_center() / get_viewport_rect().size
	var locked: Vector2 = world_map.world_buttons[2].get_global_rect().get_center() / get_viewport_rect().size
	print("SUPER_DIEGO_MAP_READY worlds=8 unlocked=world_01 forest=%.4f,%.4f locked=%.4f,%.4f" % [point.x, point.y, locked.x, locked.y])


func _toggle_motion() -> void:
	settings.menu_reduced_motion = not settings.menu_reduced_motion
	settings.save()
	_apply_motion()


func _restart_intro() -> void:
	intro.restart()
	_hero_title.restart()


func _apply_motion() -> void:
	intro.set_reduced_motion(settings.menu_reduced_motion)
	_hero_title.reduced_motion = settings.menu_reduced_motion
	_hero_title.queue_redraw()
	world_map.reduced_motion = settings.menu_reduced_motion
	motion_button.text = "Movimiento reducido: sí" if settings.menu_reduced_motion else "Movimiento reducido: no"
	motion_button.accessibility_name = motion_button.text + ". Cambiar animación del menú"
	_replay_button.visible = page == &"intro" and not settings.menu_reduced_motion


func _layout() -> void:
	_safe = Rect2(Vector2.ZERO, get_viewport_rect().size)
	var physical: Rect2i = DisplayServer.get_display_safe_area()
	if OS.has_feature("android") and physical.has_area():
		_safe = get_viewport().get_screen_transform().affine_inverse() * Rect2(physical)
	var margin := Vector2(32, 20)
	var area := Rect2(_safe.position + margin, _safe.size - margin * 2)
	motion_button.position = Vector2(area.end.x - 268, area.position.y)
	motion_button.size = Vector2(268, 52)
	back_button.position = area.position
	back_button.size = Vector2(122, 52)
	_status.position = Vector2(area.position.x, area.end.y - 44)
	_status.size = Vector2(area.size.x, 44)
	if page == &"map":
		_title.add_theme_font_size_override("font_size", 36)
		_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_title.position = Vector2(area.position.x + 145, area.position.y + 19)
		_title.size = Vector2(area.size.x - 435, 52)
		_eyebrow.position = Vector2(area.position.x + 145, area.position.y - 2)
		_eyebrow.size = Vector2(area.size.x - 435, 28)
		_eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		world_map.position = area.position + Vector2(0, 76)
		world_map.size = Vector2(area.size.x, area.size.y - 120)
	else:
		_title.add_theme_font_size_override("font_size", 88)
		_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		_title.position = area.position + Vector2(30, area.size.y * 0.20)
		_title.size = Vector2(area.size.x * 0.43, 220)
		_hero_title.position = _title.position - Vector2(18, 10)
		_hero_title.size = Vector2(area.size.x * 0.43, 230)
		_eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		_eyebrow.position = _title.position - Vector2(0, 40)
		_eyebrow.size = Vector2(480, 30)
		_subtitle.position = _title.position + Vector2(0, 225)
		_subtitle.size = Vector2(area.size.x * 0.42, 75)
		play_button.position = _subtitle.position + Vector2(0, 88)
		play_button.size = Vector2(330, 72)
		_replay_button.position = play_button.position + Vector2(0, 87)
		_replay_button.size = Vector2(330, 52)
		intro.position = _safe.position
		intro.size = _safe.size


func _request_world(world_id: String) -> void:
	if _loading:
		return
	var target: String = WorldCatalog.scene_for(world_id)
	if target.is_empty():
		_status.text = "Mundo bloqueado · Esta aventura estará disponible más adelante."
		return
	_loading = true
	_status.text = "Preparando Bosque Esmeralda…"
	for button in world_map.world_buttons:
		button.disabled = true
	back_button.disabled = true
	motion_button.disabled = true
	# Mostrar la carga antes de importar el escenario. Ignorar dobles pulsaciones.
	await get_tree().process_frame
	await get_tree().process_frame
	var error: Error = get_tree().change_scene_to_file(target)
	if error != OK:
		_loading = false
		for button in world_map.world_buttons:
			button.disabled = false
		back_button.disabled = false
		motion_button.disabled = false
		_status.text = "No se pudo abrir el bosque. Vuelve a intentarlo."


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") or event.is_action_pressed(&"pause"):
		if page == &"map":
			show_intro()
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and is_instance_valid(back_button):
		if page == &"map":
			show_intro()

