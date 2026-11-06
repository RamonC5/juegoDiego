class_name ForestPlatform
extends StaticBody2D
## Colisión independiente del recorte de terreno raster.

const TERRAIN: Texture2D = preload("res://game/assets/textures/environments/bosque_esmeralda/forest_terrain_v001.png")
var dimensions: Vector2 = Vector2(240, 64)
var is_ground: bool = false
var sand_texture: Texture2D


func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	var body := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = dimensions
	body.shape = rectangle
	body.position = dimensions / 2.0
	body.one_way_collision = not is_ground
	body.one_way_collision_margin = 8.0
	add_child(body)
	queue_redraw()


func _draw() -> void:
	if sand_texture != null:
		_draw_sand()
		return
	var image_size: Vector2 = TERRAIN.get_size()
	# El musgo empieza al 35 % de la hoja. El recorte es un recurso, sin editar el PNG.
	var source_y: float = image_size.y * 0.345
	var ratio: float = 0.36
	# El borde opaco del musgo está 53 px por debajo del recorte; alinear con y=0.
	var surface_offset: float = 19.0
	var cap_height: float = minf(dimensions.y + surface_offset, (image_size.y - source_y) * ratio)
	if is_ground:
		draw_rect(Rect2(Vector2.ZERO, dimensions), Color("30291e"))
	var x: float = 0.0
	while x < dimensions.x:
		var width: float = minf(image_size.x * ratio, dimensions.x - x)
		draw_texture_rect_region(TERRAIN, Rect2(x, -surface_offset, width, cap_height),
			Rect2(0, source_y, width / ratio, cap_height / ratio))
		x += width


func _draw_sand() -> void:
	var image_size: Vector2 = sand_texture.get_size()
	var scale_factor: float = 0.6
	var height: float = minf(dimensions.y, image_size.y * scale_factor)
	if dimensions.y > height:
		draw_rect(Rect2(0, height, dimensions.x, dimensions.y - height), Color("a47757"))
	var x: float = 0.0
	while x < dimensions.x:
		var width: float = minf(dimensions.x - x, image_size.x * scale_factor)
		draw_texture_rect_region(sand_texture, Rect2(x, 0, width, height),
			Rect2(0, 0, width / scale_factor, height / scale_factor))
		x += width
