class_name ForestSecretTotem
extends Node2D
## Señal del bosque para un acceso escondido. Arte propio dibujado en 2D.
## No bloquea a Diego: no tiene cuerpo físico ni áreas interactivas.

const ANIMATION_RADIUS: float = 390.0

var hero: DiegoPlayer
var _phase: float = 0.0
var _nearby: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	z_index = 4
	queue_redraw()


func _process(delta: float) -> void:
	var near: bool = is_instance_valid(hero) \
		and hero.global_position.distance_squared_to(global_position) < ANIMATION_RADIUS * ANIMATION_RADIUS
	if not near:
		if _nearby:
			_nearby = false
			queue_redraw()
		return
	_nearby = true
	_phase = fposmod(_phase + delta, TAU * 100.0)
	queue_redraw()


func _leaf(at: Vector2, radius: float, tint: Color) -> void:
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-radius, 1), at + Vector2(-radius * 0.18, -radius * 0.8),
		at + Vector2(radius, -radius * 0.3), at + Vector2(radius * 0.2, radius * 0.7)
	]), tint)
	draw_line(at + Vector2(-radius * 0.48, 0), at + Vector2(radius * 0.55, -radius * 0.22), Color("bce792", 0.6), 1.4, true)


func _draw() -> void:
	var sway: float = sin(_phase * 1.55) * 3.4 if _nearby else 0.0
	# Raíces anchas; la base coincide con el suelo sin impedir el paso.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-15, -24), Vector2(-41, -10), Vector2(-55, 0),
		Vector2(-19, -3), Vector2(1, -15), Vector2(24, 0),
		Vector2(50, -1), Vector2(24, -13), Vector2(18, -33)
	]), Color("50351f"))
	draw_line(Vector2(-23, -8), Vector2(-49, -2), Color("a47b43"), 3.0, true)
	draw_line(Vector2(17, -12), Vector2(41, -5), Color("b38a4b"), 2.5, true)
	# Silueta irregular: madera con corteza y una placa frontal tallada.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-31, -114), Vector2(-24, -143), Vector2(-4, -151),
		Vector2(25, -133), Vector2(30, -103), Vector2(23, -24),
		Vector2(12, -5), Vector2(-19, -8), Vector2(-29, -26)
	]), Color("56351e"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-21, -112), Vector2(-15, -135), Vector2(7, -140),
		Vector2(19, -123), Vector2(18, -39), Vector2(8, -18),
		Vector2(-14, -22), Vector2(-20, -40)
	]), Color("a77a43"))
	draw_line(Vector2(-21, -110), Vector2(-18, -37), Color("d1a664"), 3.0, true)
	draw_line(Vector2(22, -104), Vector2(18, -31), Color("6e4727"), 4.0, true)
	draw_line(Vector2(-8, -124), Vector2(-11, -91), Color("74502d"), 2.0, true)
	# Rostro amable, marcado directamente en la madera, sin rótulos.
	draw_line(Vector2(-15, -103), Vector2(-4, -107), Color("5b3b24"), 4.0, true)
	draw_line(Vector2(7, -107), Vector2(16, -103), Color("5b3b24"), 4.0, true)
	draw_circle(Vector2(-9, -96), 3.4, Color("2e3125"))
	draw_circle(Vector2(10, -96), 3.4, Color("2e3125"))
	draw_arc(Vector2(0, -86), 11, 0.22, PI - 0.22, 14, Color("5d3a24"), 3.0, true)
	# Hoja luminosa grabada en el pecho y nervadura orientada al escondite.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-1, -75), Vector2(-14, -65), Vector2(-10, -49),
		Vector2(1, -44), Vector2(12, -54), Vector2(10, -68)
	]), Color("4d7c3b"))
	draw_line(Vector2(-1, -70), Vector2(1, -49), Color("c9e5a1"), 2.4, true)
	draw_line(Vector2(0, -59), Vector2(-9, -63), Color("98c96e"), 1.5, true)
	draw_line(Vector2(0, -55), Vector2(9, -63), Color("98c96e"), 1.5, true)
	draw_line(Vector2(-8, -31), Vector2(0, -25), Color("63462b"), 3.0, true)
	draw_line(Vector2(0, -25), Vector2(8, -31), Color("63462b"), 3.0, true)
	# Copa verde que se balancea levemente al acercarse Diego.
	_leaf(Vector2(-29 + sway, -134), 22.0, Color("477c44"))
	_leaf(Vector2(12 + sway, -147), 28.0, Color("56994e"))
	_leaf(Vector2(30 + sway, -128), 20.0, Color("85bb60"))
	_leaf(Vector2(-7 + sway, -158), 22.0, Color("7fba62"))
	_leaf(Vector2(17 + sway, -164), 17.0, Color("b6d87b"))
	if _nearby:
		var pulse: float = 0.23 + 0.15 * (0.5 + 0.5 * sin(_phase * 2.5))
		draw_circle(Vector2(1, -59), 23.0, Color(0.66, 1.0, 0.49, pulse))
		for index in 3:
			var phase_offset: float = _phase * (0.65 + float(index) * 0.13) + float(index) * 1.1
			var drift: float = fposmod(phase_offset, 2.7)
			var spot := Vector2(26.0 + float(index) * 11.0 + sin(phase_offset * 2.0) * 9.0, -143.0 + drift * 32.0)
			_leaf(spot, 5.8, Color("bfda73", 0.75))
