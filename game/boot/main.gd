extends "res://game/boot/practice.gd"
## Entrada del primer nivel. Reutiliza pausa, opciones y controles del entrenamiento.

@export var level_definition: ForestLevelDefinition = preload("res://game/data/worlds/world_01/level_01.tres")

var stage: ForestStage
var progress: LevelProgress
## Inyección explícita para pruebas y composición; nunca depende de un autoload.
var collection_progress: CollectionProgress
var _collection_menu: CollectionMenu
var _wardrobe_button: Button
var _reward_toast: Button
var _toast_seconds: float = 0.0
var _reward_queue: Array[String] = []
var _applied_outfit: String = ""
var backdrop: ForestBackdrop
var _leaves_counter: HudCounter
var _crystals_counter: HudCounter
var _keys_card: HudCounter
var _hud_title: Label
var _distance: ProgressBar
var _tip_seconds: float = 9.0
var _result: Dictionary = {}
var _top_panel: PanelContainer
var _key_counter: Label
var _look_ahead: float = 125.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	settings = ControlSettings.new()
	add_child(settings)
	progress = LevelProgress.new()
	if collection_progress == null:
		collection_progress = CollectionProgress.new()
	var background_layer := CanvasLayer.new()
	background_layer.layer = -20
	add_child(background_layer)
	backdrop = ForestBackdrop.new()
	background_layer.add_child(backdrop)
	stage = ForestStage.new()
	stage.DEFINITION = level_definition
	stage.collection_progress = collection_progress
	stage.name = "BosqueEsmeralda"
	add_child(stage)
	player = PLAYER_SCENE.instantiate()
	stage.add_child(player)
	stage.start(player)
	_music = LevelMusic.new()
	add_child(_music)
	_music.play_track(level_definition.music_stream)
	_camera = Camera2D.new()
	_camera.position = Vector2(640, 360)
	_camera.position_smoothing_enabled = false
	_camera.limit_left = 0
	_camera.limit_right = int(stage.DEFINITION.width)
	_camera.limit_top = -600
	_camera.limit_bottom = 1550
	add_child(_camera)
	_build_ui()
	collection_progress.changed.connect(_apply_collection)
	collection_progress.reward_unlocked.connect(_on_reward_unlocked)
	collection_progress.save_failed.connect(func(_error: Error):
		_show_reward_toast("No se pudo guardar la colección. El objeto sigue disponible.")
	)
	_apply_collection()
	if collection_progress.count("leaf") == 0:
		_show_reward_toast("Recoge 12 hojas para desbloquear tu primer pañuelo · Colección")
	settings.changed.connect(_apply_settings)
	_apply_settings()
	player.health_changed.connect(_update_health)
	player.defeated.connect(func(): _open_menu("¡Otra oportunidad!", true))
	stage.hint_requested.connect(_show_hint)
	stage.counts_changed.connect(_update_counts)
	stage.keys_changed.connect(_update_keys)
	stage.level_completed.connect(_on_level_completed)
	get_viewport().size_changed.connect(_layout_menu)
	get_viewport().size_changed.connect(_layout_hud)
	_layout_hud()
	_update_counts(stage.leaves, stage.crystals)
	_update_keys(0, KeyExitDoor.REQUIRED_KEYS)
	_show_hint("BOSQUE ESMERALDA · Reúne tres llaves de ramas para abrir la salida. Pulsa a la izquierda para saltar y otra vez en el aire para el doble salto. Arrastra a la derecha para moverte. Puedes intercambiar los lados en pausa.")


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
	# Un desplazamiento vertical de Diego mueve la cámara la misma distancia.
	# Sin límite de velocidad: una caída a 900 px/s no puede dejar la cámara atrás.
	if not get_tree().paused:
		_camera.position.y = clampf(player.position.y - 240.0, -170.0, 1020.0)
	backdrop.camera_x = _camera.position.x
	_distance.value = clampf(player.position.x / stage.DEFINITION.goal.x * 100.0, 0.0, 100.0)
	if not get_tree().paused:
		_tip_seconds = maxf(0.0, _tip_seconds - delta)
		_message.visible = false
		if _toast_seconds > 0.0:
			_toast_seconds = maxf(0.0, _toast_seconds - delta)
			if is_zero_approx(_toast_seconds):
				_reward_toast.hide()
				if not _reward_queue.is_empty():
					_show_reward_toast(_reward_queue.pop_front())
	if player.held_object != _last_held_object:
		_last_held_object = player.held_object
		if is_instance_valid(_last_held_object):
			_show_hint("%s en las manos · Toque corto o %s para lanzar." % [
				_last_held_object.definition.display_name, settings.key_label(&"grab_throw")])


func _show_hint(text: String) -> void:
	# La ayuda escrita se consulta en pausa; el escenario usa iconos.
	_message.accessibility_description = text
	_message.text = ""
	_message.visible = false


func _update_health(value: int) -> void:
	_health_counter.set_count(value, player.maximum_health)


func _update_counts(leaves: int, crystals: int) -> void:
	_leaves_counter.set_count(leaves, stage.total_leaves)
	_crystals_counter.set_count(crystals, 3)


func _update_keys(collected: int, required: int) -> void:
	var slots := PackedStringArray()
	for index in required:
		slots.append("Llave %d %s" % [index + 1, "recogida" if stage.collected_keys.has(index) else "pendiente"])
	_keys_card.set_count(collected, required, "; ".join(slots))


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
	panel_style.content_margin_left = 14
	panel_style.content_margin_right = 14
	panel_style.content_margin_top = 8
	panel_style.content_margin_bottom = 8
	_top_panel.add_theme_stylebox_override("panel", panel_style)
	_ui.add_child(_top_panel)
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_theme_constant_override("separation", 8)
	_top_panel.add_child(column)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 10)
	column.add_child(row)
	_hud_title = Label.new()
	_hud_title.text = "1–1"
	_hud_title.accessibility_name = "Bosque Esmeralda, nivel uno"
	_hud_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hud_title.add_theme_font_size_override("font_size", 23)
	_hud_title.add_theme_color_override("font_color", Color("fff2c9"))
	_hud_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(_hud_title)
	_health_counter = HudCounter.new()
	_health_counter.configure(preload("res://game/assets/ui/hud_heart.svg"), "Energía")
	row.add_child(_health_counter)
	_health = _health_counter.value_label
	_update_health(player.health)
	_keys_card = HudCounter.new()
	_keys_card.configure(stage.DEFINITION.key_definition.icon_for(0), "Llaves")
	_keys_card.icon.material = stage.DEFINITION.key_definition.sprite_material()
	row.add_child(_keys_card)
	_key_counter = _keys_card.value_label
	_leaves_counter = HudCounter.new()
	_leaves_counter.configure(preload("res://game/assets/ui/hud_leaf.svg"), "Hojas")
	row.add_child(_leaves_counter)
	_crystals_counter = HudCounter.new()
	_crystals_counter.configure(preload("res://game/assets/ui/hud_crystal.svg"), "Cristales")
	row.add_child(_crystals_counter)
	_wardrobe_button = _button("", _open_wardrobe)
	_wardrobe_button.icon = preload("res://game/assets/ui/hud_wardrobe.svg")
	_wardrobe_button.expand_icon = true
	_wardrobe_button.add_theme_constant_override("icon_max_width", 30)
	_wardrobe_button.custom_minimum_size = Vector2(110, 54)
	_wardrobe_button.accessibility_name = "Colección y vestuario"
	row.add_child(_wardrobe_button)
	var pause_button := _button("Ⅱ", _toggle_pause)
	pause_button.tooltip_text = "Pausa y opciones"
	pause_button.accessibility_name = "Pausa y opciones"
	pause_button.custom_minimum_size = Vector2(60, 54)
	row.add_child(pause_button)
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
	touch.excluded_controls = [pause_button, _wardrobe_button]
	_ui.add_child(touch)
	_build_menu()
	_menu_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_menu_title.add_theme_font_size_override("font_size", 27)
	var version := Label.new()
	version.text = "Super Diego · Versión " + _build_version()
	version.add_theme_font_size_override("font_size", 18)
	version.add_theme_color_override("font_color", Color("d6dfcf"))
	var menu_column: Container = _menu_title.get_parent()
	menu_column.add_child(version)
	menu_column.move_child(version, 1)
	var buttons: Container = _resume_button.get_parent()
	var collection_button := _button("Colección", _open_wardrobe)
	buttons.add_child(collection_button)
	buttons.move_child(collection_button, 1)
	_collection_menu = CollectionMenu.new()
	_collection_menu.progress = collection_progress
	_collection_menu.level_id = stage.DEFINITION.level_id
	_collection_menu.total_leaves = stage.total_leaves
	_collection_menu.total_crystals = stage.DEFINITION.crystal_positions.size()
	_ui.add_child(_collection_menu)
	_collection_menu.closed.connect(_close_wardrobe)
	_reward_toast = _button("", _open_wardrobe)
	_reward_toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_reward_toast.custom_minimum_size = Vector2(0, 58)
	_reward_toast.add_theme_font_size_override("font_size", 20)
	_reward_toast.hide()
	_ui.add_child(_reward_toast)
	touch.excluded_controls.append(_reward_toast)
	buttons.add_child(_button("Entrenamiento", func():
		touch.release_all()
		get_tree().paused = false
		get_tree().change_scene_to_file("res://game/features/player/practice.tscn")
	))
	var map_button := _button("Mapa de mundos", _return_to_map)
	map_button.accessibility_description = "Salir del intento y volver al mapa. La colección y los mejores resultados se conservan; el recorrido comienza de nuevo al entrar."
	map_button.tooltip_text = map_button.accessibility_description
	buttons.add_child(map_button)
	var actions := GridContainer.new()
	actions.columns = 2
	actions.add_theme_constant_override("h_separation", 12)
	actions.add_theme_constant_override("v_separation", 10)
	var actions_column: Container = buttons.get_parent()
	actions_column.add_child(actions)
	actions_column.move_child(actions, buttons.get_index())
	for button in buttons.get_children():
		button.reparent(actions)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons.queue_free()


func _return_to_map() -> void:
	touch.release_all()
	player.controls.clear_virtual()
	player.controls.block_current_physical()
	get_tree().paused = false
	# Inyección explícita de la página de retorno, sin autoload ni estado global.
	var entrance: Control = load("res://game/boot/entrance.tscn").instantiate()
	entrance.set("initial_page", &"map")
	get_tree().root.add_child(entrance)
	get_tree().current_scene = entrance
	queue_free()


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
	_hud_title.visible = safe.size.x >= 1100
	_top_panel.size = Vector2(safe.size.x - 32, 82)
	_message.position = _top_panel.position + Vector2(0, _top_panel.size.y + 10)
	_message.size = Vector2(minf(760, safe.size.x - 32), 0)
	if is_instance_valid(_reward_toast):
		_reward_toast.position = _top_panel.position + Vector2(0, _top_panel.size.y + 12)
		_reward_toast.size = Vector2(minf(650, safe.size.x - 32), 72)


func _toggle_pause() -> void:
	if is_instance_valid(_collection_menu) and _collection_menu.visible:
		_close_wardrobe()
	elif stage.completed:
		_open_menu(_completion_text(), false)
	elif player.dead:
		_open_menu("¡Otra oportunidad!", true)
	else:
		super._toggle_pause()


func _open_menu(title: String, allow_resume: bool = true) -> void:
	if is_instance_valid(_collection_menu):
		_collection_menu.hide()
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
	_collection_menu.hide()
	super._resume()


func _apply_collection() -> void:
	if _applied_outfit != collection_progress.equipped:
		_applied_outfit = collection_progress.equipped
		player.sprite.material = PlayerWardrobe.material_for(_applied_outfit)
	var next: Dictionary = collection_progress.next_reward()
	_wardrobe_button.text = "%d/%d" % [collection_progress.count("leaf"), int(next.leaves)] if int(next.leaves) > 0 else (
		"✓" if collection_progress.is_unlocked("golden_forest") else "%d/%d" % [collection_progress.count("leaf", stage.DEFINITION.level_id), stage.total_leaves])
	_wardrobe_button.tooltip_text = "Colección · " + next.name
	_wardrobe_button.accessibility_description = "%d hojas permanentes. Próxima recompensa: %s" % [collection_progress.count("leaf"), next.name]


func _on_reward_unlocked(id: String) -> void:
	var name: String = "Luci despierta" if id == "luci" else CollectionRewards.outfit(id).name
	var message: String = "¡%s! · Toca para ver tu colección" % name
	if _toast_seconds > 0.0:
		_reward_queue.append(message)
	else:
		_show_reward_toast(message)


func _show_reward_toast(text: String) -> void:
	_reward_toast.text = text
	_reward_toast.accessibility_name = text
	_reward_toast.show()
	_toast_seconds = 6.0


func _open_wardrobe() -> void:
	_open_menu("Pausa y colección", not stage.completed)
	_menu.hide()
	_reward_toast.hide()
	_collection_menu.open()


func _close_wardrobe() -> void:
	_collection_menu.hide()
	_open_menu("Pausa y controles", not stage.completed)


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






