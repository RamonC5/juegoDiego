class_name ForestFragment
extends ForestCollectible
## Fragmento de amuleto: silueta de media hoja y anillo, distinta del cristal.

func _draw() -> void:
	var bob := Vector2(0, sin(_time * 2.0) * 3.0)
	draw_circle(bob, 28, Color(0.95, 0.80, 0.35, 0.10))
	draw_arc(bob, 23, -2.2, 2.2, 22, Color("ffe0a0"), 3.0, true)
	var leaf := PackedVector2Array([bob + Vector2(-9, 18), bob + Vector2(-15, -4),
		bob + Vector2(4, -23), bob + Vector2(14, -3), bob + Vector2(7, 12)])
	draw_colored_polygon(leaf, Color("e6b452"))
	draw_line(bob + Vector2(-7, 14), bob + Vector2(5, -18), Color("fff4cb"), 3.0, true)
