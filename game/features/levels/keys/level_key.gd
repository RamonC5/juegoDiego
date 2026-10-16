class_name LevelKey
extends Area2D
## Recogida automática independiente de los objetos que Diego lleva en las manos.

signal collected(key: LevelKey)

@export var definition: LevelKeyDefinition
@export_range(0, 2) var slot: int = 0
var taken: bool = false


func _ready() -> void:
	assert(definition != null, "Cada llave necesita una definición artística")
	collision_layer = 32
	collision_mask = 2
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 27.0
	shape.shape = circle
	add_child(shape)
	var sprite := Sprite2D.new()
	sprite.texture = definition.icon_for(slot)
	sprite.material = definition.sprite_material()
	if sprite.texture != null:
		sprite.scale = Vector2.ONE * 74.0 / maxf(sprite.texture.get_width(), sprite.texture.get_height())
	add_child(sprite)
	var number := Label.new()
	number.text = str(slot + 1)
	number.position = Vector2(-14, -62)
	number.size = Vector2(28, 27)
	number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	number.add_theme_font_size_override("font_size", 20)
	number.add_theme_color_override("font_color", Color("fff2c9"))
	var background := StyleBoxFlat.new()
	background.bg_color = Color("163c30")
	background.set_corner_radius_all(10)
	background.set_border_width_all(2)
	background.border_color = Color("ebce91")
	number.add_theme_stylebox_override("normal", background)
	add_child(number)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if taken or not body is DiegoPlayer or body.dead or body.celebrating:
		return
	taken = true
	visible = false
	set_deferred("monitoring", false)
	collected.emit(self)
