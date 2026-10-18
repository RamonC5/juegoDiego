class_name CollectionMenu
extends Control
## Vestuario accesible: vista de Diego, hitos y compañero, con foco y scroll.

signal closed
var progress: CollectionProgress
var level_id: String = CollectionRewards.FOREST_ID
var total_leaves: int = 0
var total_crystals: int = 3
var _panel: PanelContainer
var _summary: Label
var _preview: TextureRect
var _equipped_label: Label
var _helper_label: Label
var _helper_button: Button
var _close_button: Button
var _actions: Dictionary = {}
var _view_buttons: Array[Button] = []
var _selected: String = "original"
var _status: Label


static func preview_texture() -> Texture2D:
	var texture: Texture2D = preload("res://game/assets/textures/characters/diego/idle_v001.png")
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(texture.get_size() * Vector2(228.0 / 1254.0, 31.0 / 1254.0),
		texture.get_size() * Vector2(246.0 / 1254.0, 596.0 / 1254.0))
	return atlas


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.06, 0.05, 0.91)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	_panel = PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color("123b32")
	style.border_color = Color("9cbf7e")
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.content_margin_left = 22
	style.content_margin_right = 22
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	_panel.add_child(column)
	var title := Label.new()
	title.text = "Tu colección del bosque"
	title.add_theme_font_size_override("font_size", 29)
	title.add_theme_color_override("font_color", Color("fff1cb"))
	column.add_child(title)
	_summary = Label.new()
	_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_summary)
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 20)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(body)
	var portrait := VBoxContainer.new()
	portrait.custom_minimum_size.x = 180
	portrait.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	portrait.size_flags_stretch_ratio = 0.32
	body.add_child(portrait)
	_preview = TextureRect.new()
	_preview.texture = preview_texture()
	_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_preview.custom_minimum_size.y = 170
	_preview.accessibility_name = "Vista de Diego con la ropa seleccionada"
	portrait.add_child(_preview)
	_equipped_label = Label.new()
	_equipped_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_equipped_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	portrait.add_child(_equipped_label)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 12)
	scroll.add_child(list)
	for outfit in CollectionRewards.OUTFITS:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		list.add_child(row)
		var view_button := Button.new()
		view_button.text = outfit.name
		view_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		view_button.custom_minimum_size = Vector2(200, 78)
		view_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		view_button.accessibility_name = "Ver " + outfit.name
		view_button.tooltip_text = outfit.description
		view_button.pressed.connect(_select.bind(outfit.id))
		row.add_child(view_button)
		_view_buttons.append(view_button)
		var action := Button.new()
		action.custom_minimum_size = Vector2(170, 78)
		action.pressed.connect(_equip.bind(outfit.id))
		row.add_child(action)
		_actions[outfit.id] = action
	_helper_label = Label.new()
	_helper_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_helper_label)
	_helper_button = Button.new()
	_helper_button.custom_minimum_size.y = 48
	_helper_button.pressed.connect(func():
		if progress.set_helper_enabled(not progress.helper_enabled):
			_status.text = "Luci te acompaña." if progress.helper_enabled else "Luci descansa; puedes activarla cuando quieras."
	)
	column.add_child(_helper_button)
	_status = Label.new()
	_status.text = "Las hojas se acumulan: desbloquear ropa no las gasta."
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.add_theme_font_size_override("font_size", 18)
	column.add_child(_status)
	_close_button = Button.new()
	_close_button.text = "Volver a la pausa"
	_close_button.custom_minimum_size.y = 52
	_close_button.pressed.connect(func(): closed.emit())
	column.add_child(_close_button)
	progress.changed.connect(refresh)
	progress.save_failed.connect(func(_error: Error):
		_status.text = "No se ha podido guardar. El objeto sigue disponible para recogerlo."
	)
	resized.connect(_layout)
	visible = false
	refresh()
	_layout.call_deferred()


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
	_equipped_label.text = outfit.name + (" · Equipado" if progress.equipped == id else " · Vista previa")
	_status.text = outfit.description


func _equip(id: String) -> void:
	if progress.equip(id):
		_selected = id
		refresh()
		_status.text = "¡%s equipado!" % CollectionRewards.outfit(id).name


func refresh() -> void:
	if not is_instance_valid(_summary):
		return
	var next: Dictionary = progress.next_reward()
	var next_text: String = "Colección completa" if progress.is_unlocked("golden_forest") else (
		"Próximo: %s · %d / %d hojas" % [next.name, progress.count("leaf"), int(next.leaves)]
		if int(next.leaves) > 0 else "Próximo: Guardián dorado · completa la colección del bosque")
	_summary.text = "%s\nBosque: %d / %d hojas · %d / %d cristales · %d / 3 fragmentos" % [
		next_text, progress.count("leaf", level_id), total_leaves,
		progress.count("crystal", level_id), total_crystals, progress.count("fragment", level_id)]
	for outfit in CollectionRewards.OUTFITS:
		var action: Button = _actions[outfit.id]
		var unlocked: bool = progress.is_unlocked(outfit.id)
		action.disabled = not unlocked or progress.equipped == outfit.id
		action.text = "Equipado" if progress.equipped == outfit.id else ("Equipar" if unlocked else (
			"%d / %d hojas" % [progress.count("leaf"), int(outfit.leaves)] if int(outfit.leaves) > 0 else "Colección completa"))
		action.accessibility_name = outfit.name + ": " + action.text
	_helper_label.text = "Luci despierta: señala secretos y acerca hojas próximas." if progress.helper_unlocked() else (
		"Luci duerme en una planta del primer claro.\nFragmentos: %d / 3 · busca en las primeras repisas, la gruta y las lianas." % progress.count("fragment", level_id))
	_helper_button.disabled = not progress.helper_unlocked()
	_helper_button.text = ("Dejar descansar a Luci" if progress.helper_enabled else "Activar a Luci") if progress.helper_unlocked() else "Reúne los tres fragmentos para despertar a Luci"
	_select(_selected)


func _layout() -> void:
	if not is_instance_valid(_panel):
		return
	var safe := Rect2(Vector2.ZERO, get_viewport_rect().size)
	var physical: Rect2i = DisplayServer.get_display_safe_area()
	if OS.has_feature("android") and physical.has_area():
		safe = get_viewport().get_screen_transform().affine_inverse() * Rect2(physical)
	_panel.size = Vector2(minf(1040, safe.size.x - 32), minf(660, safe.size.y - 32))
	_panel.position = safe.position + (safe.size - _panel.size) / 2.0
