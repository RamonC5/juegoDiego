class_name ForestEnemy
extends CharacterBody2D
## Reutiliza el arte del catálogo con animación de patrulla y aplastamiento por transformación.

signal defeated(enemy: ForestEnemy, by_throw: bool)

const SPRITES: Dictionary = {
	"terron": preload("res://game/assets/textures/characters/terron/idle_v001.png"),
	"moflete": preload("res://game/assets/textures/characters/moflete/idle_v001.png"),
}

var kind: String = "terron"
var patrol: Vector2 = Vector2(0, 200)
var player: DiegoPlayer
var active: bool = true
var _direction: float = -1.0
var _time: float = 0.0
var _visual: Sprite2D
var _scale: float = 1.0
var _height: float = 58.0
var _stomp: StompTarget
var _contact: Area2D
var _intro_hint: Label


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	_height = 76.0 if kind == "moflete" else 52.0
	var body := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(48 if kind == "moflete" else 104, _height)
	body.shape = rectangle
	body.position.y = -_height / 2.0
	add_child(body)
	_visual = Sprite2D.new()
	_visual.texture = SPRITES[kind]
	_visual.centered = false
	# Atlas normalizado: conserva encuadre aunque Godot limite la importación a 512 px.
	var atlas := AtlasTexture.new()
	atlas.atlas = _visual.texture
	var rect: Rect2 = _opaque_region(atlas.atlas)
	atlas.region = rect
	_visual.texture = atlas
	_scale = (_height + 8.0) / rect.size.y
	_visual.offset = Vector2(-rect.size.x / 2.0, -rect.size.y)
	_visual.scale = Vector2.ONE * _scale
	var material := ShaderMaterial.new()
	material.shader = preload("res://game/features/player/sprite_alpha.gdshader")
	_visual.material = material
	add_child(_visual)
	_stomp = StompTarget.new()
	_stomp.position.y = -_height
	_stomp.collision_layer = 64
	_stomp.collision_mask = 0
	_stomp.half_width = 30.0 if kind == "moflete" else 54.0
	_stomp.top_tolerance = 16.0
	var sensor_shape := CollisionShape2D.new()
	var top := RectangleShape2D.new()
	top.size = Vector2(58 if kind == "moflete" else 110, 18)
	sensor_shape.shape = top
	_stomp.add_child(sensor_shape)
	add_child(_stomp)
	_stomp.stomped.connect(func(_hero: Node2D): defeat(false))
	_contact = Area2D.new()
	_contact.collision_layer = 0
	_contact.collision_mask = 2
	var contact_shape := CollisionShape2D.new()
	contact_shape.shape = rectangle
	contact_shape.position = body.position
	_contact.add_child(contact_shape)
	add_child(_contact)


func show_intro_hint() -> void:
	# Terrón comparte colores con el suelo: presentar el primer combate con texto.
	_intro_hint = Label.new()
	_intro_hint.text = "ENEMIGO · %s\nSalta encima" % ("MOFLETE" if kind == "moflete" else "TERRÓN")
	_intro_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_intro_hint.position = Vector2(-110, -_height - 72)
	_intro_hint.size = Vector2(220, 60)
	_intro_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_intro_hint.add_theme_font_size_override("font_size", 20)
	_intro_hint.add_theme_color_override("font_color", Color("fff2c9"))
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0.025, 0.12, 0.10, 0.94)
	background.set_corner_radius_all(8)
	background.content_margin_top = 4
	background.content_margin_bottom = 4
	_intro_hint.add_theme_stylebox_override("normal", background)
	add_child(_intro_hint)


func has_visible_art() -> bool:
	if not is_instance_valid(_visual) or not _visual.is_visible_in_tree():
		return false
	var atlas := _visual.texture as AtlasTexture
	return atlas != null and atlas.atlas != null and atlas.region.has_area()


func _opaque_region(texture: Texture2D) -> Rect2:
	# Metadatos de los conceptos originales: margen transparente, sin recortar archivos.
	var size: Vector2 = texture.get_size()
	var normalized := Rect2(0.0215, 0.3198, 0.9665, 0.4482) if kind == "terron" else Rect2(0.2321, 0.1212, 0.5997, 0.7887)
	return Rect2(size * normalized.position, size * normalized.size)


func _physics_process(delta: float) -> void:
	if not active:
		return
	_time += delta
	if position.x <= patrol.x:
		_direction = 1.0
	elif position.x >= patrol.y:
		_direction = -1.0
	velocity.x = _direction * (58.0 if kind == "moflete" else 43.0)
	velocity.y = minf(velocity.y + 1700.0 * delta, 900.0)
	move_and_slide()
	if is_on_wall():
		_direction *= -1.0
	_visual.flip_h = _direction < 0.0
	_visual.position.y = -absf(sin(_time * 8.0)) * 2.5
	_visual.rotation = sin(_time * 8.0) * 0.035
	_visual.scale = Vector2(1.0 + sin(_time * 8.0) * 0.025, 1.0) * _scale
	if is_instance_valid(player) and not player.dead and _contact.overlaps_body(player):
		if player.global_position.y > global_position.y - _height + 16.0:
			player.take_damage(global_position)


func receive_thrown_hit(object: ThrowableObject) -> void:
	if active and object.can_cause_thrown_damage():
		defeat(true)


func defeat(by_throw: bool) -> void:
	if not active:
		return
	active = false
	if is_instance_valid(_intro_hint):
		_intro_hint.hide()
	_stomp.enabled = false
	set_deferred("collision_layer", 0)
	_contact.set_deferred("monitoring", false)
	defeated.emit(self, by_throw)
	var tween := create_tween()
	tween.tween_property(_visual, "scale", Vector2(1.35, 0.2) * _scale, 0.14)
	tween.tween_interval(0.22)
	tween.tween_property(_visual, "modulate:a", 0.0, 0.25)
	tween.tween_callback(queue_free)

