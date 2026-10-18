class_name SuperheroTitle
extends Control
## Nombre original con letras inclinadas, relieve coral y contorno azul/dorado.

var reduced_motion: bool = false
var clock: float = 0.0
var _font: FontVariation


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	accessibility_name = "Super Diego"
	_font = FontVariation.new()
	_font.base_font = ThemeDB.fallback_font
	_font.variation_embolden = 2.0
	_font.variation_transform = Transform2D(Vector2(1, 0), Vector2(-0.18, 1), Vector2.ZERO)
	resized.connect(queue_redraw)


func restart() -> void:
	clock = 0.0
	queue_redraw()


func _process(delta: float) -> void:
	if is_visible_in_tree() and not reduced_motion:
		clock += delta
		if clock < 1.0:
			queue_redraw()


func _draw() -> void:
	if not is_instance_valid(_font) or size.x <= 0.0:
		return
	var progress: float = 1.0 if reduced_motion else clampf(clock / 0.72, 0.0, 1.0)
	var pop: float = 1.0 + sin(progress * PI) * 0.065
	var factor: float = minf(size.x / 480.0, size.y / 230.0)
	draw_set_transform(Vector2(12, 8) + Vector2(225, 105) * factor * (1.0 - pop), -0.045, Vector2.ONE * factor * pop)
	var shield := PackedVector2Array([Vector2(12, 65), Vector2(421, 45), Vector2(390, 164), Vector2(217, 213), Vector2(43, 174)])
	draw_colored_polygon(shield, Color("113f67"))
	draw_polyline(PackedVector2Array([shield[0], shield[1], shield[2], shield[3], shield[4], shield[0]]), Color("55b8cf"), 3.0, true)
	for shift in [Vector2.ZERO, Vector2(369, -23)]:
		var bolt := PackedVector2Array([Vector2(0, 99), Vector2(39, 83), Vector2(26, 109), Vector2(57, 103), Vector2(8, 145), Vector2(20, 116)])
		for index in bolt.size():
			bolt[index] += shift
		draw_colored_polygon(bolt, Color("ffc74b"))
	_word("SUPER", Vector2(60, 89), 71, Color("fff1a8"))
	_word("DIEGO", Vector2(35, 175), 101, Color("ffd04e"))
	draw_set_transform(Vector2.ZERO)


func _word(value: String, baseline: Vector2, font_size: int, fill: Color) -> void:
	draw_string_outline(_font, baseline + Vector2(9, 12), value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 16, Color("071f39"))
	for depth in range(8, 0, -1):
		draw_string_outline(_font, baseline + Vector2(depth, depth), value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 8, Color("dc514b"))
	draw_string_outline(_font, baseline, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 10, Color("092947"))
	draw_string_outline(_font, baseline, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 3, Color("fff4cf"))
	draw_string(_font, baseline, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, fill)
