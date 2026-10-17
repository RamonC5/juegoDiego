class_name KeyExitDoor
extends Node2D
## Puerta reutilizable: tres ranuras distintas, barrera física y sensor de entrada.

signal entry_requested(body: Node2D)

const REQUIRED_KEYS: int = 3

@export var key_definition: LevelKeyDefinition
@export var panel_texture: Texture2D
@export var panel_region: Rect2 = Rect2(0, 0, 1, 1)

var is_open: bool = false
var _found: Dictionary = {}
var _icons: Array[Texture2D] = []
var _barrier: CollisionShape2D
var _sensor: Area2D
var _panel: Node2D


func _ready() -> void:
	if key_definition != null:
		material = key_definition.sprite_material()
	_panel = Node2D.new()
	_panel.z_index = -1
	_panel.position = Vector2(-58, -199)
	add_child(_panel)
	if panel_texture != null:
		var atlas := AtlasTexture.new()
		atlas.atlas = panel_texture
		atlas.region = Rect2(panel_region.position * panel_texture.get_size(), panel_region.size * panel_texture.get_size())
		var sprite := Sprite2D.new()
		sprite.texture = atlas
		sprite.material = key_definition.sprite_material() if key_definition != null else null
		sprite.centered = false
		sprite.scale = Vector2(116, 199) / atlas.get_size()
		_panel.add_child(sprite)
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 2
	_barrier = CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(108, 194)
	_barrier.shape = rectangle
	_barrier.position = Vector2(0, -97)
	body.add_child(_barrier)
	add_child(body)
	_sensor = Area2D.new()
	_sensor.collision_layer = 0
	_sensor.collision_mask = 2
	var sensor_shape := CollisionShape2D.new()
	var sensor_rectangle := RectangleShape2D.new()
	sensor_rectangle.size = Vector2(240, 220)
	sensor_shape.shape = sensor_rectangle
	sensor_shape.position = Vector2(0, -90)
	_sensor.add_child(sensor_shape)
	_sensor.body_entered.connect(func(actor: Node2D): entry_requested.emit(actor))
	add_child(_sensor)
	for index in REQUIRED_KEYS:
		_icons.append(key_definition.icon_for(index) if key_definition != null else null)
		var number := Label.new()
		number.text = str(index + 1)
		number.position = Vector2((index - 1) * 31 - 10, -145)
		number.size = Vector2(20, 26)
		number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		number.add_theme_font_size_override("font_size", 18)
		number.add_theme_color_override("font_shadow_color", Color("092b25"))
		number.add_theme_constant_override("shadow_outline_size", 4)
		add_child(number)
	_refresh(false)


func set_keys(collected_slots: Array[int]) -> void:
	_found.clear()
	for slot in collected_slots:
		if slot >= 0 and slot < REQUIRED_KEYS:
			_found[slot] = true
	_refresh(true)


func _refresh(animate: bool) -> void:
	var was_open: bool = is_open
	is_open = _found.size() == REQUIRED_KEYS
	if _barrier == null:
		return
	_barrier.set_deferred("disabled", is_open)
	if is_open and not was_open and animate:
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(_panel, "scale:x", 0.04, 0.4)
		tween.tween_property(_panel, "modulate:a", 0.0, 0.4)
	else:
		_panel.scale.x = 0.04 if is_open else 1.0
		_panel.modulate.a = 0.0 if is_open else 1.0
	queue_redraw()


func _physics_process(_delta: float) -> void:
	# También abre si la tercera llave se recoge sin abandonar el sensor de salida.
	if not is_open or _sensor == null:
		return
	for body in _sensor.get_overlapping_bodies():
		if body is DiegoPlayer and not body.dead and not body.celebrating:
			entry_requested.emit(body)


func _draw() -> void:
	for index in REQUIRED_KEYS:
		var at := Vector2((index - 1) * 31, -112)
		draw_circle(at, 14.0, Color("15352c"))
		draw_arc(at, 14.0, 0.0, TAU, 32, Color("ebce91"), 2.0, true)
		if _found.has(index) and index < _icons.size() and _icons[index] != null:
			draw_texture_rect(_icons[index], Rect2(at - Vector2(11, 11), Vector2(22, 22)), false)
		else:
			draw_circle(at + Vector2(0, -3), 3.0, Color("ebce91"))
			draw_line(at + Vector2(0, -1), at + Vector2(0, 7), Color("ebce91"), 3.0, true)

