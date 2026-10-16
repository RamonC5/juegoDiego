class_name ThrowableObject
extends CharacterBody2D
## Entidad arrojadiza independiente del dibujo y de la animación del protagonista.

signal thrown
signal hit_target(target: Node)
signal bounced
signal broken
signal returned_to_spawn

enum State { FREE, HELD, THROWN, BROKEN }

const MINIMUM_DAMAGE_SPEED: float = 120.0
const ART_SHADER: Shader = preload("res://game/features/player/sprite_alpha.gdshader")

@export var definition: ThrowableDefinition = preload("res://game/features/objects/definitions/barril_raices.tres")
## Solo el entrenamiento activa la reposición automática; cero la desactiva.
@export var respawn_delay: float = 0.0
## Vacío para niveles sin recuperación; el entrenamiento asigna su área explícita.
@export var recovery_bounds: Rect2 = Rect2()

var state: State = State.FREE
var _world: Node
var _spawn_position: Vector2
var _flight_time: float = 0.0
var _bounce_count: int = 0
var _return_time: float = -1.0
var _grounded: bool = false
var _visual: Sprite2D
var _base_scale: float = 1.0
var _squash: float = 0.0


func _ready() -> void:
	collision_layer = 8
	collision_mask = 1 | 4 | 64
	_world = get_parent()
	_spawn_position = global_position
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = definition.collision_radius
	shape.shape = circle
	add_child(shape)
	_visual = Sprite2D.new()
	_visual.texture = definition.make_sprite_texture()
	_visual.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_base_scale = definition.display_width / _visual.texture.get_width()
	_visual.scale = Vector2.ONE * _base_scale
	var material := ShaderMaterial.new()
	material.shader = ART_SHADER
	_visual.material = material
	add_child(_visual)


func can_be_picked_up() -> bool:
	return state == State.FREE


func can_cause_thrown_damage() -> bool:
	return state == State.THROWN and _flight_time <= definition.flight_seconds \
		and velocity.length() >= MINIMUM_DAMAGE_SPEED


func pick_up(anchor: Node2D) -> void:
	if not can_be_picked_up():
		return
	_world = get_parent()
	state = State.HELD
	velocity = Vector2.ZERO
	collision_layer = 0
	collision_mask = 0
	_return_time = -1.0
	_visual.rotation = 0.0
	_visual.scale = Vector2.ONE * _base_scale
	_squash = 0.0
	reparent(anchor, false)
	position = Vector2.ZERO
	rotation = 0.0
	scale = Vector2.ONE


func release(direction: float, inherited_velocity: Vector2, launch: bool = true) -> void:
	if state != State.HELD:
		return
	var origin: Vector2 = global_position
	reparent(_world, true)
	global_position = origin
	# La mano puede estar reflejada al mirar a la izquierda; el cuerpo físico no.
	rotation = 0.0
	scale = Vector2.ONE
	state = State.THROWN if launch else State.FREE
	collision_layer = 8
	collision_mask = 1 | 4 | 64
	velocity = Vector2(signf(direction) * definition.launch_speed, -definition.launch_lift) \
		+ inherited_velocity * 0.25
	if not launch:
		velocity = Vector2(signf(direction) * 60.0, -30.0)
	_flight_time = 0.0
	_bounce_count = 0
	_grounded = false
	# Una suelta por daño también debe recuperarse aunque quede apoyada dentro del área.
	_return_time = respawn_delay if not launch and respawn_delay > 0.0 else -1.0
	if launch:
		thrown.emit()


func _physics_process(delta: float) -> void:
	if state == State.HELD:
		return
	if _return_time >= 0.0:
		_return_time -= delta
		if _return_time <= 0.0:
			reset_to_spawn()
	if state == State.BROKEN:
		return
	if state == State.THROWN:
		_flight_time += delta
		if not can_cause_thrown_damage():
			_settle()
	if state == State.FREE or _grounded:
		velocity.x = move_toward(velocity.x, 0.0, definition.ground_drag * delta)
	velocity.y = minf(velocity.y + definition.gravity * delta, 900.0)
	var motion: Vector2 = velocity * delta
	_grounded = false
	# Barrido físico y remanente: los objetos rápidos no saltan paredes finas.
	for _attempt in 4:
		if motion.length_squared() < 0.000001:
			break
		var collision: KinematicCollision2D = move_and_collide(motion, false, 0.08, true)
		if collision == null:
			break
		var normal: Vector2 = collision.get_normal()
		var floor_hit: bool = normal.y < -0.6
		_grounded = _grounded or floor_hit
		var target: Object = collision.get_collider()
		if can_cause_thrown_damage() and target.has_method("receive_thrown_hit"):
			# El receptor valida su vulnerabilidad antes de consumir el impacto.
			target.receive_thrown_hit(self)
			hit_target.emit(target)
			if definition.break_on_impact:
				_break_apart()
			else:
				_settle()
			velocity = Vector2.ZERO
			break
		if state == State.THROWN and definition.break_on_impact:
			_break_apart()
			break
		if state == State.THROWN and floor_hit \
			and definition.ground_behavior == ThrowableDefinition.GroundBehavior.BOUNCE \
			and _bounce_count < definition.maximum_bounces and velocity.y > 100.0:
			velocity = velocity.bounce(normal) * definition.restitution
			motion = collision.get_remainder().bounce(normal) * definition.restitution
			_bounce_count += 1
			_squash = 0.12
			bounced.emit()
			continue
		velocity = velocity.slide(normal)
		motion = collision.get_remainder().slide(normal)
		if state == State.THROWN:
			var keeps_moving: bool = floor_hit and definition.ground_behavior in [
				ThrowableDefinition.GroundBehavior.ROLL, ThrowableDefinition.GroundBehavior.SLIDE]
			if not keeps_moving or absf(velocity.x) < MINIMUM_DAMAGE_SPEED:
				if floor_hit:
					velocity.x = 0.0
					motion.x = 0.0
				_settle()
	_update_visual(delta)
	if recovery_bounds.has_area() and not recovery_bounds.has_point(global_position):
		reset_to_spawn()


func _update_visual(delta: float) -> void:
	if state == State.THROWN:
		if _grounded and definition.ground_behavior == ThrowableDefinition.GroundBehavior.SLIDE:
			_visual.rotation = lerp_angle(_visual.rotation, 0.0, minf(1.0, delta * 12.0))
		else:
			var spin: float = velocity.x / definition.collision_radius if _grounded \
				else definition.spin_speed * signf(velocity.x)
			_visual.rotation += spin * delta
	elif state == State.FREE:
		_visual.rotation = lerp_angle(_visual.rotation, 0.0, minf(1.0, delta * 10.0))
	_squash = maxf(0.0, _squash - delta)
	var amount: float = _squash / 0.12
	_visual.scale = Vector2(1.0 + amount * 0.18, 1.0 - amount * 0.18) * _base_scale


func _settle() -> void:
	state = State.FREE
	if respawn_delay > 0.0 and _return_time < 0.0:
		_return_time = respawn_delay


func _break_apart() -> void:
	state = State.BROKEN
	collision_layer = 0
	collision_mask = 0
	velocity = Vector2.ZERO
	visible = false
	if respawn_delay > 0.0:
		_return_time = respawn_delay
	broken.emit()


func reset_to_spawn() -> void:
	if state == State.HELD:
		return
	global_position = _spawn_position
	rotation = 0.0
	scale = Vector2.ONE
	velocity = Vector2.ZERO
	state = State.FREE
	collision_layer = 8
	collision_mask = 1 | 4 | 64
	visible = true
	_flight_time = 0.0
	_bounce_count = 0
	_return_time = -1.0
	_grounded = false
	_squash = 0.0
	_visual.rotation = 0.0
	_visual.scale = Vector2.ONE * _base_scale
	returned_to_spawn.emit()
