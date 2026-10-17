class_name HudCounter
extends PanelContainer
## Icono reconocible y cantidad; los gestos atraviesan todo el contador.

var value_label: Label
var icon: TextureRect
var caption: String


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(122, 52)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("183b30")
	style.set_corner_radius_all(12)
	style.set_border_width_all(1)
	style.border_color = Color("426450")
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	add_theme_stylebox_override("panel", style)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 9)
	add_child(row)
	icon = TextureRect.new()
	icon.custom_minimum_size = Vector2(34, 34)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(icon)
	value_label = Label.new()
	value_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	value_label.add_theme_font_size_override("font_size", 26)
	value_label.add_theme_color_override("font_color", Color("fff4d7"))
	row.add_child(value_label)


func configure(texture: Texture2D, label: String) -> void:
	icon.texture = texture
	caption = label
	accessibility_name = label
	value_label.accessibility_name = label


func set_count(current: int, total: int, details: String = "") -> void:
	value_label.text = "%d / %d" % [current, total]
	var description: String = "%s: %d de %d" % [caption, current, total]
	if not details.is_empty():
		description += ". " + details
	tooltip_text = description
	accessibility_description = description
	value_label.accessibility_description = description
