class_name ForestThrowTarget
extends StaticBody2D
## El jugador atraviesa el sensor; solo los arrojadizos consultan esta capa física.

signal activated(mechanism_id: StringName)

const TEXTURE: Texture2D = preload("res://game/assets/textures/environments/bosque_esmeralda/mechanisms/throw_target_v001.png")

var definition: RootBridgeDefinition
var active: bool = true
var _caption: Label
var _sprite: Sprite2D
var caption: String = ""
var show_connection: bool = true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	position = definition.target_position
	collision_layer = 64
	collision_mask = 8
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 58.0
	shape.shape = circle
	add_child(shape)
	_sprite = Sprite2D.new()
	_sprite.texture = TEXTURE
	_sprite.scale = Vector2.ONE * 136.0 / maxf(TEXTURE.get_width(), TEXTURE.get_height())
	var material := ShaderMaterial.new()
	material.shader = preload("res://game/features/player/sprite_alpha.gdshader")
	_sprite.material = material
	add_child(_sprite)
	_caption = Label.new()
	_caption.text = "ENSAYO · LANZA AQUÍ" if definition.tutorial else "PUENTE · LANZA AQUÍ"
	if not caption.is_empty():
		_caption.text = caption
	_caption.position = Vector2(-145, -116)
	_caption.size = Vector2(290, 40)
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.add_theme_font_size_override("font_size", 20)
	_caption.add_theme_color_override("font_color", Color("fff3cb"))
	_caption.add_theme_color_override("font_shadow_color", Color("092b25"))
	_caption.add_theme_constant_override("shadow_outline_size", 7)
	add_child(_caption)
	queue_redraw()


func receive_thrown_hit(object: ThrowableObject) -> void:
	if not active or not is_instance_valid(object) or not object.can_cause_thrown_damage():
		return
	active = false
	set_deferred("collision_layer", 0)
	_sprite.scale *= 0.94
	_caption.text = "DIANA ACTIVADA ✓"
	queue_redraw()
	activated.emit(definition.mechanism_id)


func restore_activated() -> void:
	if active:
		active = false
		set_deferred("collision_layer", 0)
		_sprite.scale *= 0.94
	_caption.text = "DIANA ACTIVADA ✓"
	queue_redraw()


func _draw() -> void:
	# Poste y raíz de conexión: la relación con el puente se ve incluso sin audio.
	draw_line(Vector2(0, 54), Vector2(0, 72), Color("382b1c"), 13, true)
	var connection: Vector2 = definition.bridge_rect.position - position + Vector2(14, 13)
	if show_connection:
		draw_polyline(PackedVector2Array([Vector2(0, 65), Vector2(32, 76), connection]), Color("59482d"), 7, true)
	if not active:
		draw_circle(Vector2.ZERO, 27, Color("12382e"))
		draw_polyline(PackedVector2Array([Vector2(-15, 0), Vector2(-3, 12), Vector2(18, -14)]), Color("fff3cb"), 6, true)

