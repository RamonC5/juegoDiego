class_name WorldCue
extends Node2D
## Señales geométricas legibles sin texto, fuente ni dependencia del color.

enum Kind { THROW, STOMP, CHECKPOINT, HORIZONTAL, VERTICAL, EXIT, ALERT }
var kind: Kind = Kind.THROW
var activated: bool = false:
	set(value):
		activated = value
		queue_redraw()


func _draw() -> void:
	var ink := Color("fff3cb")
	draw_circle(Vector2.ZERO, 25, Color("12382e"))
	draw_arc(Vector2.ZERO, 25, 0, TAU, 40, Color("ebce91"), 2, true)
	if activated:
		draw_polyline(PackedVector2Array([Vector2(-13, 0), Vector2(-3, 10), Vector2(14, -11)]), ink, 5, true)
		return
	match kind:
		Kind.THROW:
			draw_circle(Vector2(-12, 8), 5, ink)
			draw_arc(Vector2(-8, 10), 20, -PI / 2.0, -0.15, 20, ink, 3, true)
			_arrow(Vector2(12, -3), Vector2(0, 9), ink)
		Kind.STOMP:
			_arrow(Vector2(0, -15), Vector2(0, 11), ink)
			draw_line(Vector2(-13, 16), Vector2(13, 16), ink, 4, true)
		Kind.CHECKPOINT:
			draw_line(Vector2(-8, 15), Vector2(-8, -16), ink, 4, true)
			draw_colored_polygon(PackedVector2Array([Vector2(-6, -15), Vector2(14, -10), Vector2(-6, -3)]), ink)
		Kind.HORIZONTAL:
			_arrow(Vector2(-16, 0), Vector2(16, 0), ink)
			_arrow(Vector2(16, 0), Vector2(-16, 0), ink)
		Kind.VERTICAL:
			_arrow(Vector2(0, 16), Vector2(0, -16), ink)
			_arrow(Vector2(0, -16), Vector2(0, 16), ink)
		Kind.EXIT:
			draw_rect(Rect2(-13, -16, 21, 32), ink, false, 3)
			_arrow(Vector2(-5, 0), Vector2(18, 0), ink)
		Kind.ALERT:
			draw_line(Vector2(0, -14), Vector2(0, 4), ink, 5, true)
			draw_circle(Vector2(0, 13), 3, ink)


func _arrow(from: Vector2, to: Vector2, ink: Color) -> void:
	draw_line(from, to, ink, 3, true)
	var direction: Vector2 = (to - from).normalized()
	var side := direction.orthogonal() * 6.0
	draw_polyline(PackedVector2Array([to - direction * 7 + side, to, to - direction * 7 - side]), ink, 3, true)
