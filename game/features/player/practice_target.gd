extends StaticBody2D
## Diana geométrica de entrenamiento, sin representar a un enemigo del catálogo.

signal completed

@export var kind: StringName = &"stomp"
var active: bool = true


func _ready() -> void:
	collision_layer = 4
	collision_mask = 2 | 8
	var body := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(80, 40 if kind == &"stomp" else 100)
	body.shape = rectangle
	body.position.y = -rectangle.size.y / 2.0
	add_child(body)
	if kind == &"stomp":
		var sensor := StompTarget.new()
		sensor.position.y = -40.0
		sensor.collision_layer = 64
		sensor.collision_mask = 0
		sensor.half_width = 40.0
		var sensor_shape := CollisionShape2D.new()
		var top := RectangleShape2D.new()
		top.size = Vector2(76, 12)
		sensor_shape.shape = top
		sensor.add_child(sensor_shape)
		add_child(sensor)
		sensor.stomped.connect(func(_player: Node2D): _complete())


func receive_thrown_hit(object: ThrowableObject) -> void:
	if kind == &"throw" and object.can_cause_thrown_damage():
		_complete()


func _complete() -> void:
	if not active:
		return
	active = false
	set_deferred("collision_layer", 0)
	queue_redraw()
	completed.emit()


func _draw() -> void:
	if not active:
		return
	var height: float = 40.0 if kind == &"stomp" else 100.0
	var rectangle := Rect2(-40, -height, 80, height)
	draw_rect(rectangle, Color("e7b969") if active else Color("a1c4ae"))
	draw_rect(rectangle, Color("23474a"), false, 3.0)
	if active and kind == &"stomp":
		draw_line(Vector2(-24, -33), Vector2(0, -14), Color("23474a"), 4.0, true)
		draw_line(Vector2(0, -14), Vector2(24, -33), Color("23474a"), 4.0, true)
	elif active:
		draw_arc(Vector2(0, -50), 27, 0, TAU, 32, Color("23474a"), 4.0, true)
		draw_circle(Vector2(0, -50), 9, Color("23474a"))

