extends Node2D
## Composición de la prueba del protagonista. No define mundos ni progreso.

const PLAYER_SCENE: PackedScene = preload("res://game/features/player/diego.tscn")
const STAGE_SCRIPT = preload("res://game/features/player/practice_stage.gd")
const TARGET_SCRIPT = preload("res://game/features/player/practice_target.gd")
const ACTION_LABELS: Dictionary = {&"move_left": "Izquierda", &"move_right": "Derecha",
	&"jump": "Saltar", &"crouch": "Agacharse", &"grab_throw": "Coger / lanzar", &"run": "Correr", &"pause": "Pausa"}

var player: DiegoPlayer
var _music: LevelMusic
var _music_slider: HSlider
var settings: ControlSettings
var touch: HeroTouchControls
var _camera: Camera2D
var _ui: Control
var _health: Label
var _health_counter: HudCounter
var _message: Label
var _menu: Control
var _panel: PanelContainer
var _menu_title: Label
var _resume_button: Button
var _remap_buttons: Dictionary = {}
var _waiting_action: StringName = &""
var _key_hint: Label
var _check_boxes: Dictionary = {}
var _last_held_object: ThrowableObject


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	settings = ControlSettings.new()
	add_child(settings)
	var stage := Node2D.new()
	stage.name = "PracticeStage"
	stage.set_script(STAGE_SCRIPT)
	add_child(stage)
	player = PLAYER_SCENE.instantiate()
	player.position = Vector2(160, 500)
	stage.add_child(player)
	_camera = Camera2D.new()
	_camera.position = Vector2(640, 360)
	_camera.position_smoothing_enabled = false
	_camera.limit_left = 0
	_camera.limit_right = 2900
	_camera.limit_top = -200
	_camera.limit_bottom = 1100
	add_child(_camera)
	_add_throwable_objects(stage)
	for spec in [[&"throw", Vector2(520, 500)], [&"stomp", Vector2(730, 500)]]:
		var target := StaticBody2D.new()
		target.set_script(TARGET_SCRIPT)
		target.kind = spec[0]
		target.position = spec[1]
		stage.add_child(target)
		target.completed.connect(func(): _message.text = "¡Bien hecho! Sigue practicando hacia la derecha.")
	_add_goal(stage)
	_build_ui()
	settings.changed.connect(_apply_settings)
	_apply_settings()
	player.health_changed.connect(_update_health)
	player.defeated.connect(func(): _open_menu("¡Otra oportunidad!", false))
	get_viewport().size_changed.connect(_layout_menu)


func _process(_delta: float) -> void:
	if is_instance_valid(player):
		var half_width: float = get_viewport_rect().size.x / 2.0
		_camera.position.x = clampf(player.position.x, half_width, maxf(half_width, 2900.0-half_width))
		if player.held_object != _last_held_object:
			_last_held_object = player.held_object
			if is_instance_valid(_last_held_object):
				_message.text = "%s · %s Toque corto o %s para lanzar." % [
					_last_held_object.definition.display_name, _last_held_object.definition.description,
					settings.key_label(&"grab_throw")]
			else:
				_message.text = "Prueba los seis objetos. Los usados reaparecen en su puesto."


func _add_throwable_objects(stage: Node2D) -> void:
	const POSITIONS: Array[float] = [270.0, 360.0, 450.0, 590.0, 660.0, 840.0]
	for index in ThrowableCatalog.DEFINITIONS.size():
		var object := ThrowableObject.new()
		object.definition = ThrowableCatalog.DEFINITIONS[index]
		object.position = Vector2(POSITIONS[index], 470)
		object.respawn_delay = 3.0
		object.recovery_bounds = Rect2(-200, -600, 3600, 1800)
		stage.add_child(object)
		object.broken.connect(func():
			_message.text = "Vasija rota. Volverá a su puesto en 3 segundos."
		)


func _add_goal(stage: Node2D) -> void:
	var goal := Area2D.new()
	goal.position = Vector2(2680, 440)
	goal.collision_layer = 64
	goal.collision_mask = 2
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(90, 120)
	shape.shape = rectangle
	goal.add_child(shape)
	stage.add_child(goal)
	goal.body_entered.connect(func(body: Node2D):
		if body == player:
			player.celebrate()
			_message.text = "¡Prueba completada! Abre Pausa para volver a jugar."
	)


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_ui = Control.new()
	_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_ui)
	var theme := Theme.new()
	theme.default_font_size = 21
	var focus := StyleBoxFlat.new()
	focus.bg_color = Color(0, 0, 0, 0)
	focus.set_border_width_all(3)
	focus.border_color = Color("ffd27d")
	theme.set_stylebox("focus", "Button", focus)
	theme.set_stylebox("focus", "CheckBox", focus)
	theme.set_icon("checked", "CheckBox", preload("res://game/assets/ui/checkbox_on.svg"))
	theme.set_icon("unchecked", "CheckBox", preload("res://game/assets/ui/checkbox_off.svg"))
	_ui.theme = theme
	var top := PanelContainer.new()
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.offset_bottom = 126.0
	_ui.add_child(top)
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_"+side, 16)
	top.add_child(margin)
	var header := VBoxContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(header)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 18)
	header.add_child(row)
	var title := Label.new()
	title.text = ""
	title.accessibility_name = "Super Diego, entrenamiento"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 25)
	row.add_child(title)
	_health_counter = HudCounter.new()
	_health_counter.configure(preload("res://game/assets/ui/hud_heart.svg"), "Energía")
	row.add_child(_health_counter)
	_health = _health_counter.value_label
	_update_health(player.health)
	var pause_button := _button("Ⅱ", func(): _toggle_pause())
	pause_button.accessibility_name = "Pausa y opciones"
	pause_button.custom_minimum_size = Vector2(60, 58)
	row.add_child(pause_button)
	_message = Label.new()
	_message.text = "Prueba seis objetos: toque corto para coger o lanzar. Teclado: %s." % settings.key_label(&"grab_throw")
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message.hide()
	header.add_child(_message)
	touch = HeroTouchControls.new()
	touch.settings = settings
	touch.input_source = player.controls
	touch.excluded_controls = [pause_button]
	_ui.add_child(touch)
	_build_menu()


func _build_menu() -> void:
	_menu = Control.new()
	_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ui.add_child(_menu)
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.05, 0.07, 0.85)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_menu.add_child(shade)
	_panel = PanelContainer.new()
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("172c32")
	panel_style.set_corner_radius_all(10)
	_panel.add_theme_stylebox_override("panel", panel_style)
	_menu.add_child(_panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_"+side, 20)
	_panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 13)
	margin.add_child(column)
	_menu_title = Label.new()
	_menu_title.add_theme_font_size_override("font_size", 30)
	column.add_child(_menu_title)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 12)
	column.add_child(buttons)
	_resume_button = _button("Continuar", _resume)
	_resume_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons.add_child(_resume_button)
	var restart_button := _button("Volver a empezar", _restart)
	restart_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons.add_child(restart_button)
	if get_script().resource_path == "res://game/boot/practice.gd":
		buttons.add_child(_button("Bosque Esmeralda", func():
			touch.release_all()
			get_tree().paused = false
			get_tree().change_scene_to_file("res://game/boot/main.tscn")
		))
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 13)
	scroll.add_child(box)
	var instructions := Label.new()
	instructions.text = "GESTOS SIN BOTONES\nEn cualquier punto de la mitad de movimiento, arrastra ← →. Un arrastre corto camina; uno largo corre. Suelta para parar.\nEn la otra mitad, desliza ↑ para saltar y mantén el dedo para ganar altura. Desliza ↓ y mantén para agacharte; suelta para levantarte cuando haya espacio. Un toque corto coge o lanza. Puedes usar varios dedos a la vez.\nTeclado inicial: A / D, Espacio, S / ↓ y E. Mando: A salta, abajo agacha, X actúa, Start pausa."
	instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(instructions)
	for spec in [["Correr también con arrastres cortos / teclado", "automatic_run"],
		["Salto completo sin mantener", "full_jump"],
		["Activar gestos táctiles y de ratón en Windows", "show_touch"],
		["Intercambiar las zonas izquierda y derecha", "left_handed"]]:
		var checkbox := CheckBox.new()
		checkbox.text = spec[0]
		checkbox.button_pressed = settings.get(spec[1])
		checkbox.custom_minimum_size.y = 48
		box.add_child(checkbox)
		_check_boxes[spec[1]] = checkbox
		checkbox.toggled.connect(func(value: bool):
			settings.set(spec[1], value)
			settings.save()
		)
	var music_label := Label.new()
	music_label.text = "Volumen de música (0 = silencio)"
	box.add_child(music_label)
	_music_slider = HSlider.new()
	_music_slider.min_value = 0
	_music_slider.max_value = 100
	_music_slider.step = 5
	_music_slider.value = settings.music_volume * 100.0
	_music_slider.custom_minimum_size.y = 48
	_music_slider.accessibility_name = "Volumen de música; cero silencia"
	box.add_child(_music_slider)
	_music_slider.value_changed.connect(func(value: float):
		settings.music_volume = value / 100.0
		settings.save()
	)
	var size_label := Label.new()
	size_label.text = "Recorrido de los gestos (menor = menos arrastre)"
	box.add_child(size_label)
	var slider := HSlider.new()
	slider.min_value = 0.8
	slider.max_value = 1.4
	slider.step = 0.1
	slider.value = settings.gesture_scale
	slider.custom_minimum_size.y = 48
	slider.tooltip_text = "Ajusta con las flechas o arrastrando"
	box.add_child(slider)
	slider.value_changed.connect(func(value: float):
		settings.gesture_scale = value
		settings.save()
	)
	_key_hint = Label.new()
	_key_hint.text = "Teclado: pulsa una acción para cambiar su tecla."
	_key_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_key_hint)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 8)
	box.add_child(grid)
	for action in ControlSettings.ACTIONS:
		var label := Label.new()
		label.text = ACTION_LABELS[action]
		grid.add_child(label)
		var button := _button(settings.key_label(action), func():
			_waiting_action = action
			_key_hint.text = "Pulsa la nueva tecla para %s. Escape cancela." % ACTION_LABELS[action]
		)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(button)
		_remap_buttons[action] = button
	box.add_child(_button("Restablecer teclas", func():
		_waiting_action = &""
		settings.reset_keys()
	))
	_menu.visible = false
	_layout_menu()


func _button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 52
	button.pressed.connect(callback)
	return button


func _layout_menu() -> void:
	if not is_instance_valid(_panel):
		return
	var view: Vector2 = get_viewport_rect().size
	_panel.size = Vector2(minf(720, view.x-40), minf(650, view.y-40))
	_panel.position = (view - _panel.size) / 2.0


func _apply_settings() -> void:
	if is_instance_valid(_music):
		_music.set_music_volume(settings.music_volume)
	if is_instance_valid(_music_slider):
		_music_slider.set_value_no_signal(settings.music_volume * 100.0)
	player.controls.automatic_run = settings.automatic_run
	player.controls.full_jump = settings.full_jump
	for property in _check_boxes:
		_check_boxes[property].set_pressed_no_signal(bool(settings.get(property)))
	for action in _remap_buttons:
		_remap_buttons[action].text = settings.key_label(action)


func _input(event: InputEvent) -> void:
	if _waiting_action.is_empty() or not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_ESCAPE:
		_waiting_action = &""
		_key_hint.text = "Cambio cancelado."
	elif settings.rebind(_waiting_action, int(event.physical_keycode)):
		_waiting_action = &""
		_key_hint.text = "Tecla guardada."
	else:
		_key_hint.text = "Esa tecla ya está asignada. Elige otra o pulsa Escape."
	get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause") and not event.is_echo():
		_toggle_pause()
		get_viewport().set_input_as_handled()


func _toggle_pause() -> void:
	if get_tree().paused and not player.dead:
		_resume()
	else:
		_open_menu("Pausa y controles", not player.dead)


func _open_menu(title: String, allow_resume: bool = true) -> void:
	_waiting_action = &""
	touch.release_all()
	player.suspend_controls()
	get_tree().paused = true
	_menu_title.text = title
	_resume_button.disabled = not allow_resume
	_menu.visible = true
	if allow_resume:
		_resume_button.grab_focus()
	else:
		_resume_button.find_next_valid_focus().grab_focus()


func _resume() -> void:
	_waiting_action = &""
	touch.release_all()
	_menu.visible = false
	player.controls.enabled = true
	player.controls.block_current_physical()
	get_tree().paused = false


func _restart() -> void:
	touch.release_all()
	get_tree().paused = false
	get_tree().reload_current_scene()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(touch):
		_open_menu("Partida en pausa", not player.dead)





func _update_health(value: int) -> void:
	_health_counter.set_count(value, 3)

