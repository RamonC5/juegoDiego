class_name ForestRootGate
extends StaticBody2D
## Raíces verticales: las dos marcas geométricas explican el progreso sin depender del color.

var definition: ForestRootGateDefinition
var activated: Array[StringName] = []
var is_open: bool = false
var _shape: CollisionShape2D
var _roots: Node2D


func _ready() -> void:
	position = definition.position
	collision_layer = 1
	collision_mask = 0
	_shape = CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(76, 1280)
	_shape.shape = rectangle
	_shape.position = Vector2(0, -640)
	add_child(_shape)
	_roots = Node2D.new()
	add_child(_roots)
	var texture: Texture2D = RootBridge.TEXTURE
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(texture.get_size() * Vector2(0.007, 0.26), texture.get_size() * Vector2(0.987, 0.52))
	for index in 4:
		var sprite := Sprite2D.new()
		sprite.texture = atlas
		sprite.scale = Vector2(350.0 / atlas.get_width(), 90.0 / atlas.get_height())
		sprite.rotation = PI / 2.0
		sprite.position = Vector2(0, -160.0 - index * 320.0)
		_roots.add_child(sprite)
	queue_redraw()


func activate_station(id: StringName) -> void:
	if activated.has(id):
		return
	for station in definition.stations:
		if station.mechanism_id == id:
			activated.append(id)
			if activated.size() == definition.stations.size():
				is_open = true
				_shape.set_deferred("disabled", true)
				var tween := create_tween()
				tween.tween_property(_roots, "scale:x", 0.12, 0.45)
				tween.parallel().tween_property(_roots, "modulate:a", 0.0, 0.45)
			queue_redraw()
			return


func _draw() -> void:
	for index in definition.stations.size():
		var at := Vector2((index - 0.5) * 64.0, -230)
		draw_circle(at, 24, Color("12382e"))
		draw_arc(at, 24, 0, TAU, 32, Color("ebce91"), 3, true)
		if activated.has(definition.stations[index].mechanism_id):
			draw_polyline(PackedVector2Array([at + Vector2(-13, 0), at + Vector2(-3, 10), at + Vector2(14, -11)]), Color("fff3cb"), 5, true)
		else:
			draw_arc(at, 12, 0, TAU, 24, Color("fff3cb"), 3, true)
			draw_circle(at, 4, Color("fff3cb"))
