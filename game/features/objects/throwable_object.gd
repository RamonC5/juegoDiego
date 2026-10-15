class_name ThrowableObject
extends CharacterBody2D
## Objeto de práctica. Solo un objeto en vuelo puede causar un impacto lanzado.

signal thrown
signal hit_target(target: Node)

enum State { FREE, HELD, THROWN }

var state: State = State.FREE
var _world: Node
var _flight_time: float = 0.0


func _ready() -> void:
	collision_layer = 8
	collision_mask = 1 | 4
	_world = get_parent()
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 15.0
	shape.shape = circle
	add_child(shape)
	queue_redraw()


func can_be_picked_up() -> bool:
	return state == State.FREE


func pick_up(anchor: Node2D) -> void:
	if not can_be_picked_up():
		return
	_world = get_parent()
	state = State.HELD
	velocity = Vector2.ZERO
	collision_layer = 0
	collision_mask = 0
	reparent(anchor, false)
	position = Vector2.ZERO


func release(direction: float, inherited_velocity: Vector2, launch: bool = true) -> void:
	if state != State.HELD:
		return
	var origin: Vector2 = global_position
	reparent(_world, true)
	global_position = origin
	state = State.THROWN if launch else State.FREE
	collision_layer = 8
	collision_mask = 1 | 4
	velocity = Vector2(direction * 620.0, -180.0) + inherited_velocity * 0.25
	if not launch:
		velocity = Vector2(direction * 60.0, -30.0)
	_flight_time = 0.0
	if launch:
		thrown.emit()


func _physics_process(delta: float) -> void:
	if state == State.HELD:
		return
	velocity.y = minf(velocity.y + 1200.0 * delta, 900.0)
	if state == State.FREE:
		velocity.x = move_toward(velocity.x, 0.0, 500.0 * delta)
	move_and_slide()
	if state == State.THROWN:
		_flight_time += delta
		for index in get_slide_collision_count():
			var target: Object = get_slide_collision(index).get_collider()
			if target.has_method("receive_thrown_hit"):
				target.receive_thrown_hit(self)
				hit_target.emit(target)
			state = State.FREE
			break
		if _flight_time > 2.0:
			state = State.FREE
	if global_position.y > 1200.0:
		global_position = Vector2(330.0, 450.0)
		velocity = Vector2.ZERO
		state = State.FREE


func _draw() -> void:
	draw_circle(Vector2.ZERO, 15.0, Color("eab75b"))
	draw_arc(Vector2.ZERO, 15.0, 0.0, TAU, 32, Color("3c3023"), 3.0, true)
	draw_line(Vector2(-9, 0), Vector2(9, 0), Color("3c3023"), 3.0, true)
	draw_line(Vector2(0, -9), Vector2(0, 9), Color("3c3023"), 3.0, true)
