class_name ForestRootGate
extends StaticBody2D
## Raíces verticales: abrir físicamente el paso comunica su estado, sin rótulos ni iconos.

var definition: ForestRootGateDefinition
var activated: Array[StringName] = []
var is_open: bool = false
var _shape: CollisionShape2D
var _roots: Node2D
var _opening_tween: Tween


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
				_opening_tween = create_tween()
				_opening_tween.tween_property(_roots, "scale:x", 0.12, 0.45)
				_opening_tween.parallel().tween_property(_roots, "modulate:a", 0.0, 0.45)
			queue_redraw()
			return



func reset_closed() -> void:
	# Anula la desaparición en curso, restaura el bloqueo y las dos estaciones.
	if _opening_tween != null and _opening_tween.is_running():
		_opening_tween.kill()
	_opening_tween = null
	activated.clear()
	is_open = false
	_shape.set_deferred("disabled", false)
	_roots.scale = Vector2.ONE
	_roots.modulate = Color.WHITE
	queue_redraw()
