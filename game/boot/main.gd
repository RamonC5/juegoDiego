extends "res://game/boot/practice.gd"
## Entrada del primer nivel. Reutiliza pausa, opciones y controles del entrenamiento.

@export var level_definition: ForestLevelDefinition = preload("res://game/data/worlds/world_01/level_01.tres")

var stage: ForestStage
var progress: LevelProgress
var backdrop: ForestBackdrop
var _stats: Label
var _distance: ProgressBar
var _tip_seconds: float = 9.0
var _result: Dictionary = {}
var _top_panel: PanelContainer
var _key_counter: Label
var _key_icons: Array[TextureRect] = []
var _key_numbers: Array[Label] = []
var _look_ahead: float = 125.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	settings = ControlSettings.new()
	add_child(settings)
	progress = LevelProgress.new()
	var background_layer := CanvasLayer.new()
	background_layer.layer = -20
	add_child(background_layer)
	backdrop = ForestBackdrop.new()
	background_layer.add_child(backdrop)
	stage = ForestStage.new()
	stage.DEFINITION = level_definition
	stage.name = "BosqueEsmeralda"
	add_child(stage)
	player = PLAYER_SCENE.instantiate()
	stage.add_child(player)
	stage.start(player)
	_camera = Camera2D.new()
	_camera.position = Vector2(640, 360)
	_camera.position_smoothing_enabled = false
	_camera.limit_left = 0
	_camera.limit_right = int(stage.DEFINITION.width)
	_camera.limit_top = -600
	_camera.limit_bottom = 1200
	add_child(_camera)
	_build_ui()
	settings.changed.connect(_apply_settings)
	_apply_settings()
	player.health_changed.connect(func(value: int): _health.text = "Energía  %d / 3" % value)
	player.defeated.connect(func(): _open_menu("¡Otra oportunidad!", true))
	stage.hint_requested.connect(_show_hint)
	stage.counts_changed.connect(_update_counts)
	stage.keys_changed.connect(_update_keys)
	stage.level_completed.connect(_on_level_completed)
	get_viewport().size_changed.connect(_layout_menu)
	get_viewport().size_changed.connect(_layout_hud)
	_layout_hud()
	_update_counts(0, 0)
	_update_keys(0, KeyExitDoor.REQUIRED_KEYS)
	_show_hint("BOSQUE ESMERALDA · Reúne tres llaves de ramas para abrir la salida. Arrastra para moverte y desliza ↑ en la otra mitad para saltar.")


func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	var half_width: float = get_viewport_rect().size.x / 2.0
	var desired_look_ahead: float = 125.0
	for bridge in stage.bridges:
		if player.position.x >= bridge.definition.pine_position.x - 100.0 \
			and player.position.x <= bridge.definition.bridge_rect.end.x + 100.0:
			desired_look_ahead = 300.0
	if not get_tree().paused:
		_look_ahead = move_toward(_look_ahead, desired_look_ahead, delta * 300.0)
	_camera.position.x = clampf(player.position.x + _look_ahead, half_width,
		maxf(half_width, stage.DEFINITION.width - half_width))
	# El ascensor necesita aire sobre la repisa para dejar al personaje fuera del HUD y las pistas.
	var camera_top: float = -170.0
	var desired_camera_y: float = clampf(player.position.y - 240.0, camera_top, 580.0)
	if not get_tree().paused:
		_camera.position.y = move_toward(_camera.position.y, desired_camera_y, delta * 260.0)
	backdrop.camera_x = _camera.position.x
	_distance.value = clampf(player.position.x / stage.DEFINITION.goal.x * 100.0, 0.0, 100.0)
	if not get_tree().paused:
		_tip_seconds = maxf(0.0, _tip_seconds - delta)
		_message.visible = _tip_seconds > 0.0
	if player.held_object != _last_held_object:
		_last_held_object = player.held_object
		if is_instance_valid(_last_held_object):
			_show_hint("%s en las manos · Toque corto o %s para lanzar." % [
				_last_held_object.definition.display_name, settings.key_label(&"grab_throw")])


func _show_hint(text: String) -> void:
	_message.text = text
	_tip_seconds = 7.0
	_message.visible = true


func _update_counts(leaves: int, crystals: int) -> void:
	_stats.text = "Hojas  %d / %d     Cristales  %d / 3" % [leaves, stage.total_leaves, crystals]


func _update_keys(collected: int, required: int) -> void:
	_key_counter.text = "Llaves  %d / %d" % [collected, required]
	for index in _key_icons.size():
		var found: bool = stage.collected_keys.has(index)
		_key_icons[index].modulate.a = 1.0 if found else 0.28
		_key_numbers[index].text = "%d %s" % [index + 1, "✓" if found else "–"]
		_key_icons[index].tooltip_text = "Llave %d · %s" % [index + 1, "recogida" if found else "pendiente"]


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
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
	_top_panel = PanelContainer.new()
	_top_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.025, 0.12, 0.10, 0.94)
	panel_style.set_corner_radius_all(14)
	panel_style.content_margin_left = 20
	panel_style.content_margin_right = 14
	panel_style.content_margin_top = 8
	panel_style.content_margin_bottom = 8
	_top_panel.add_theme_stylebox_override("panel", panel_style)
	_ui.add_child(_top_panel)
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_top_panel.add_child(column)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 18)
	column.add_child(row)
	var title := Label.new()
	title.text = "1–1  BOSQUE ESMERALDA"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 25)
	title.add_theme_color_override("font_color", Color("fff2c9"))
	row.add_child(title)
	_health = Label.new()
	_health.text = "Energía  3 / 3"
	row.add_child(_health)
	_stats = Label.new()
	var pause_button := _button("Pausa", _toggle_pause)
	pause_button.custom_minimum_size = Vector2(110, 54)
	row.add_child(pause_button)
	var status_row := HBoxContainer.new()
	status_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_row.add_theme_constant_override("separation", 12)
	column.add_child(status_row)
	_key_counter = Label.new()
	status_row.add_child(_key_counter)
	for index in KeyExitDoor.REQUIRED_KEYS:
		var icon := TextureRect.new()
		icon.texture = stage.DEFINITION.key_definition.icon_for(index)
		icon.material = stage.DEFINITION.key_definition.sprite_material()
		icon.custom_minimum_size = Vector2(34, 34)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		status_row.add_child(icon)
		_key_icons.append(icon)
		var number := Label.new()
		number.custom_minimum_size.x = 43
		status_row.add_child(number)
		_key_numbers.append(number)
	_stats.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status_row.add_child(_stats)
	_distance = ProgressBar.new()
	_distance.custom_minimum_size.y = 4
	_distance.show_percentage = false
	_distance.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("b8df99")
	fill.set_corner_radius_all(2)
	_distance.add_theme_stylebox_override("fill", fill)
	column.add_child(_distance)
	_message = Label.new()
	_message.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message.add_theme_font_size_override("font_size", 21)
	_message.add_theme_color_override("font_color", Color("fff3d0"))
	var hint_style := StyleBoxFlat.new()
	hint_style.bg_color = Color(0.025, 0.12, 0.10, 0.91)
	hint_style.set_corner_radius_all(10)
	hint_style.content_margin_left = 16
	hint_style.content_margin_right = 16
	hint_style.content_margin_top = 10
	hint_style.content_margin_bottom = 10
	_message.add_theme_stylebox_override("normal", hint_style)
	_ui.add_child(_message)
	touch = HeroTouchControls.new()
	touch.settings = settings
	touch.input_source = player.controls
	touch.excluded_controls = [pause_button]
	_ui.add_child(touch)
	_build_menu()
	_menu_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_menu_title.add_theme_font_size_override("font_size", 27)
	var version := Label.new()
	version.text = "Versión " + _build_version()
	version.add_theme_font_size_override("font_size", 18)
	version.add_theme_color_override("font_color", Color("d6dfcf"))
	var menu_column: Container = _menu_title.get_parent()
	menu_column.add_child(version)
	menu_column.move_child(version, 1)
	var buttons: Container = _resume_button.get_parent()
	buttons.add_child(_button("Entrenamiento", func():
		touch.release_all()
		get_tree().paused = false
		get_tree().change_scene_to_file("res://game/features/player/practice.tscn")
	))


func _build_version() -> String:
	var fallback: String = ProjectSettings.get_setting("application/config/version", "")
	var path := "res://builds/android/build-info.json"
	if not FileAccess.file_exists(path):
		return fallback
	var info: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if info is Dictionary:
		return str(info.get("version_name", fallback))
	return fallback


func _layout_hud() -> void:
	var view: Vector2 = get_viewport_rect().size
	var safe := Rect2(Vector2.ZERO, view)
	var physical: Rect2i = DisplayServer.get_display_safe_area()
	if OS.has_feature("android") and physical.has_area():
		var inverse: Transform2D = get_viewport().get_screen_transform().affine_inverse()
		safe = inverse * Rect2(physical)
	_top_panel.position = safe.position + Vector2(16, 12)
	_top_panel.size = Vector2(safe.size.x - 32, 126)
	_message.position = _top_panel.position + Vector2(0, _top_panel.size.y + 10)
	_message.size = Vector2(minf(760, safe.size.x - 32), 0)


func _toggle_pause() -> void:
	if stage.completed:
		_open_menu(_completion_text(), false)
	elif player.dead:
		_open_menu("¡Otra oportunidad!", true)
	else:
		super._toggle_pause()


func _open_menu(title: String, allow_resume: bool = true) -> void:
	if is_instance_valid(stage) and stage.completed:
		title = _completion_text()
		allow_resume = false
	super._open_menu(title, allow_resume)
	_resume_button.text = "Volver al farol" if player.dead else "Continuar"


func _resume() -> void:
	if stage.completed:
		return
	if player.dead:
		stage.respawn_player()
	super._resume()


func _on_level_completed(level_id: String, result: Dictionary) -> void:
	_result = result
	_result["saved"] = progress.record_completion(level_id, result) == OK
	_show_hint("¡Bosque Esmeralda completado! Puedes volver a jugar para encontrar los tres cristales.")
	get_tree().create_timer(1.6, false).timeout.connect(func():
		_open_menu(_completion_text(), false)
	)


func _completion_text() -> String:
	var elapsed: int = int(_result.get("seconds", 0.0))
	return "¡Bosque Esmeralda completado!\nLlaves %d / 3 · Hojas %d / %d · Cristales %d / 3\nTiempo %d:%02d · %s" % [
		int(_result.get("keys", 0)), int(_result.get("leaves", 0)), stage.total_leaves, int(_result.get("crystals", 0)),
		elapsed / 60, elapsed % 60,
		"Resultado guardado. ¡Puedes rejugar!" if _result.get("saved", false) else "No se pudo guardar este resultado.",
	]


