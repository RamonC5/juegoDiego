class_name ForestBackdrop
extends Node2D
## Fondo en CanvasLayer: parallax limitado, sin cámaras 3D ni sacudidas.

const BACKGROUND: Texture2D = preload("res://game/assets/textures/environments/bosque_esmeralda/forest_backdrop_v001.png")
var camera_x: float = 640.0
var _time: float = 0.0


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var size: Vector2 = get_viewport_rect().size
	var width: float = size.y * BACKGROUND.get_width() / BACKGROUND.get_height()
	var offset: float = fposmod(camera_x * 0.17, width * 2.0)
	var start: int = int(floor((camera_x * 0.17) / width))
	for index in range(-1, int(ceil(size.x / width)) + 3):
		var x: float = index * width - fposmod(offset, width)
		if (start + index) % 2 == 0:
			draw_texture_rect(BACKGROUND, Rect2(x, 0, width + 1, size.y), false)
		else:
			draw_set_transform(Vector2(x + width, 0), 0.0, Vector2(-1, 1))
			draw_texture_rect(BACKGROUND, Rect2(0, 0, width + 1, size.y), false)
			draw_set_transform(Vector2.ZERO)
	# Motas pequeñas de luz continua; no parpadean ni ocultan el recorrido.
	for index in 26:
		var x: float = fposmod(index * 173.0 - camera_x * 0.3 + _time * 5.0, size.x)
		var y: float = 190.0 + fposmod(index * 89.0, maxf(100.0, size.y - 300.0))
		y += sin(_time * 0.45 + index) * 7.0
		draw_circle(Vector2(x, y), 1.5, Color(1, 0.94, 0.65, 0.45))
