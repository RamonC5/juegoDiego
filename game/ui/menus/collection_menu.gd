class_name CollectionMenu
extends Control
## Cabecera fija, catálogo desplazable y vista previa que comparte el material del juego.

signal closed
signal play_requested
var progress: CollectionProgress
var level_id: String = CollectionRewards.FOREST_ID
var total_leaves: int = 0
var total_crystals: int = 3
var _panel: Panel
var _header: HBoxContainer
var _body: HBoxContainer
var _portrait: PanelContainer
var _summary: Label
var _preview: TextureRect
var _equipped_label: Label
var _selection_label: Label
var _helper_label: Label
var _helper_button: Button
var _close_button: Button
var _play_button: Button
var _actions: Dictionary = {}
var _view_buttons: Array[Button] = []
var _cards: Dictionary = {}
var _requirements: Dictionary = {}
var _bars: Dictionary = {}
var _selected: String = "original"
var _status: Label


static func preview_texture() -> Texture2D:
	var texture: Texture2D = preload("res://game/assets/textures/characters/diego/idle_v001.png")
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(texture.get_size() * Vector2(228.0 / 1254.0, 31.0 / 1254.0),
		texture.get_size() * Vector2(246.0 / 1254.0, 596.0 / 1254.0))
	return atlas


func _style(fill: Color, border: Color, padding: int = 14) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.content_margin_left = padding
	style.content_margin_right = padding
	style.content_margin_top = padding
	style.content_margin_bottom = padding
	return style


func _button(text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(120, 52)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pressed.connect(action)
	return button


func _label(text: String, font_size: int = 18, color: Color = Color("c3d2e5")) -> Label:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var palette := Theme.new()
	palette.default_font_size = 18
	for state in ["normal", "hover", "pressed", "disabled"]:
		palette.set_stylebox(state, "Button", _style(Color("20354c") if state != "disabled" else Color("19293d"), Color("57718a"), 10))
	palette.set_stylebox("hover", "Button", _style(Color("304e66"), Color("8ceac7"), 10))
	var focus := _style(Color.TRANSPARENT, Color("ffe4a0"), 0)
	focus.set_border_width_all(4)
	palette.set_stylebox("focus", "Button", focus)
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		palette.set_color(state, "Button", Color("f4f8ff"))
	palette.set_color("font_disabled_color", "Button", Color("bdcbdc"))
	theme = palette
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.035, 0.07, 0.96)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	# Un Panel, sin mínimo impuesto por el catálogo: nunca crece fuera del área segura.
	_panel = Panel.new()
	_panel.add_theme_stylebox_override("panel", _style(Color("102034"), Color("3b536e"), 0))
	add_child(_panel)
	_header = HBoxContainer.new()
	_header.add_theme_constant_override("separation", 12)
	_panel.add_child(_header)
	var title := _label("Tu equipación", 30, Color("f5f8ff"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_header.add_child(title)
	_play_button = _button("Seguir jugando", func(): play_requested.emit())
	_play_button.custom_minimum_size.x = 170
	_header.add_child(_play_button)
	_close_button = _button("‹  Volver", func(): closed.emit())
	_close_button.accessibility_name = "Volver a la pausa"
	_header.add_child(_close_button)
	_summary = _label("")
	_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_panel.add_child(_summary)
	_body = HBoxContainer.new()
	_body.add_theme_constant_override("separation", 18)
	_panel.add_child(_body)
	_portrait = PanelContainer.new()
	_portrait.add_theme_stylebox_override("panel", _style(Color("1b3149"), Color("3d6074"), 16))
	_body.add_child(_portrait)
	var portrait_column := VBoxContainer.new()
	portrait_column.add_theme_constant_override("separation", 8)
	_portrait.add_child(portrait_column)
	_selection_label = _label("", 23, Color("f5f8ff"))
	_selection_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_selection_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	portrait_column.add_child(_selection_label)
	_equipped_label = _label("", 17)
	_equipped_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	portrait_column.add_child(_equipped_label)
	_preview = TextureRect.new()
	_preview.texture = preview_texture()
	_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_preview.accessibility_name = "Diego con la equipación seleccionada"
	portrait_column.add_child(_preview)
	var caption := _label("Prueba · Elige · Equipa", 17, Color("8ceac7"))
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	portrait_column.add_child(caption)
	var scroll := ScrollContainer.new()
	scroll.name = "RewardScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 12)
	scroll.add_child(list)
	for outfit in CollectionRewards.OUTFITS:
		_add_outfit(list, outfit)
	var helper_card := PanelContainer.new()
	helper_card.add_theme_stylebox_override("panel", _style(Color("1a3040"), Color("6e9a84")))
	list.add_child(helper_card)
	var helper_column := VBoxContainer.new()
	helper_column.add_theme_constant_override("separation", 10)
	helper_card.add_child(helper_column)
	helper_column.add_child(_label("Luci · Tu compañera de aventuras", 22, Color("ceef9f")))
	_helper_label = _label("")
	_helper_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	helper_column.add_child(_helper_label)
	_helper_button = _button("", func():
		if progress.set_helper_enabled(not progress.helper_enabled):
			_status.text = "Luci te acompaña." if progress.helper_enabled else "Luci descansa. Puedes activarla cuando quieras."
	)
	helper_column.add_child(_helper_button)
	_status = _label("Las hojas desbloquean equipo sin gastarse.", 17)
	_status.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_panel.add_child(_status)
	progress.changed.connect(refresh)
	progress.save_failed.connect(func(_error: Error):
		_status.text = "No se ha podido guardar. Tu equipo anterior se conserva."
	)
	resized.connect(_layout)
	visible = false
	refresh()
	_layout.call_deferred()


func _add_outfit(list: VBoxContainer, outfit: Dictionary) -> void:
	var accent := Color(outfit.accent)
	var card := PanelContainer.new()
	card.custom_minimum_size.y = 132
	list.add_child(card)
	_cards[outfit.id] = card
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	card.add_child(row)
	var thumbnail := TextureRect.new()
	thumbnail.texture = preview_texture()
	thumbnail.material = PlayerWardrobe.material_for(outfit.id)
	thumbnail.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	thumbnail.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	thumbnail.custom_minimum_size = Vector2(64, 100)
	thumbnail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(thumbnail)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 6)
	row.add_child(info)
	var view_button := _button(outfit.name, _select.bind(outfit.id))
	view_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	view_button.custom_minimum_size = Vector2(0, 48)
	view_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	view_button.add_theme_color_override("font_color", accent)
	view_button.accessibility_name = "Probar " + outfit.name
	view_button.tooltip_text = outfit.description
	info.add_child(view_button)
	_view_buttons.append(view_button)
	var requirement := _label("", 17)
	requirement.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(requirement)
	_requirements[outfit.id] = requirement
	var bar := ProgressBar.new()
	bar.custom_minimum_size.y = 6
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_theme_stylebox_override("background", _style(Color("0d1b2b"), Color("0d1b2b"), 0))
	bar.add_theme_stylebox_override("fill", _style(accent, accent, 0))
	info.add_child(bar)
	_bars[outfit.id] = bar
	var action := _button("", _equip.bind(outfit.id))
	action.custom_minimum_size.x = 132
	action.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(action)
	_actions[outfit.id] = action


func open() -> void:
	_selected = progress.equipped
	refresh()
	show()
	_layout()
	_close_button.grab_focus()


func _select(id: String) -> void:
	_selected = id
	_preview.material = PlayerWardrobe.material_for(id)
	var outfit: Dictionary = CollectionRewards.outfit(id)
	_preview.accessibility_description = outfit.name + ". " + outfit.description
	_selection_label.text = outfit.name
	_equipped_label.text = "✓ Equipado" if progress.equipped == id else (
		"Disponible para equipar" if progress.is_unlocked(id) else "Vista previa · Bloqueado")
	_equipped_label.add_theme_color_override("font_color", Color(outfit.accent))
	_portrait.add_theme_stylebox_override("panel", _style(Color("1b3149"), Color(outfit.accent), 16))
	_status.text = outfit.description
	for entry in CollectionRewards.OUTFITS:
		var selected: bool = entry.id == id
		_cards[entry.id].add_theme_stylebox_override("panel", _style(
			Color("243c52") if selected else Color("182a40"),
			Color(entry.accent) if selected else Color("354b64"), 12))


func _equip(id: String) -> void:
	if progress.equip(id):
		_selected = id
		refresh()
		_status.text = "¡%s equipado! Lo verás al seguir jugando." % CollectionRewards.outfit(id).name


func refresh() -> void:
	if not is_instance_valid(_summary):
		return
	var next: Dictionary = progress.next_reward()
	var next_text: String = "¡Colección completa!" if progress.is_unlocked("golden_forest") else (
		"Próximo: %s · %d / %d hojas" % [next.name, progress.count("leaf"), int(next.leaves)]
		if int(next.leaves) > 0 else "Próximo: Guardián dorado · completa el bosque")
	_summary.text = "%d / %d equipaciones · %d / %d hojas · %d / %d cristales · %d / 3 fragmentos\n%s" % [
		progress.unlocked_outfits().size(), CollectionRewards.OUTFITS.size(),
		progress.count("leaf", level_id), total_leaves, progress.count("crystal", level_id),
		total_crystals, progress.count("fragment", level_id), next_text]
	for outfit in CollectionRewards.OUTFITS:
		var action: Button = _actions[outfit.id]
		var unlocked: bool = progress.is_unlocked(outfit.id)
		var equipped: bool = progress.equipped == outfit.id
		action.disabled = not unlocked or equipped
		action.text = "✓ Equipado" if equipped else ("Equipar" if unlocked else "Bloqueado")
		action.accessibility_name = outfit.name + ": " + action.text
		var requirement: Label = _requirements[outfit.id]
		requirement.text = ("En uso · " if equipped else "Desbloqueado · ") if unlocked else "Pendiente · "
		requirement.text += ("Desde el inicio" if int(outfit.leaves) == 0 else (
			"%d / %d hojas" % [mini(progress.count("leaf"), int(outfit.leaves)), int(outfit.leaves)]
			if int(outfit.leaves) > 0 else "Todas las hojas, cristales y fragmentos"))
		var bar: ProgressBar = _bars[outfit.id]
		bar.max_value = maxi(1, int(outfit.leaves)) if int(outfit.leaves) >= 0 else maxi(1, total_leaves + total_crystals + 3)
		bar.value = bar.max_value if unlocked else (
			progress.count("leaf") if int(outfit.leaves) > 0 else
			progress.count("leaf", level_id) + progress.count("crystal", level_id) + progress.count("fragment", level_id))
	_helper_label.text = "Desbloqueada · Señala secretos y acerca hojas próximas." if progress.helper_unlocked() else (
		"Fragmentos: %d / 3 · Busca en las primeras repisas, la gruta y las lianas." % progress.count("fragment", level_id))
	_helper_button.disabled = not progress.helper_unlocked()
	_helper_button.text = ("Dejar descansar a Luci" if progress.helper_enabled else "Activar a Luci") if progress.helper_unlocked() else "Luci está bloqueada · Reúne tres fragmentos"
	_select(_selected)


func _layout() -> void:
	if not is_instance_valid(_panel):
		return
	var safe := Rect2(Vector2.ZERO, get_viewport_rect().size)
	var physical: Rect2i = DisplayServer.get_display_safe_area()
	if OS.has_feature("android") and physical.has_area():
		safe = get_viewport().get_screen_transform().affine_inverse() * Rect2(physical)
	_panel.size = Vector2(minf(1140, safe.size.x - 24), minf(680, safe.size.y - 24))
	_panel.position = safe.position + (safe.size - _panel.size) / 2.0
	_header.position = Vector2(20, 16)
	_header.size = Vector2(_panel.size.x - 40, 56)
	_summary.position = Vector2(20, 84)
	_summary.size = Vector2(_panel.size.x - 40, 56)
	_body.position = Vector2(20, 148)
	_body.size = Vector2(_panel.size.x - 40, maxf(100, _panel.size.y - 202))
	_portrait.custom_minimum_size.x = clampf(_panel.size.x * 0.25, 200, 280)
	_status.position = Vector2(20, _panel.size.y - 40)
	_status.size = Vector2(_panel.size.x - 40, 28)

