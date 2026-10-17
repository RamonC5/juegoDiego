class_name DiegoPlayer
extends CharacterBody2D

signal health_changed(health: int)
signal defeated
signal jumped
signal bounced
signal object_released
signal state_changed(state: StringName)

@export var tuning: PlayerTuning = preload("res://game/features/player/default_tuning.tres")
@export var maximum_health: int = 3
@export var fall_limit_y: float = 1100.0

@onready var controls: PlayerInputSource = $InputSource
@onready var sprite: AnimatedSprite2D = $Facing/Sprite
@onready var facing_node: Node2D = $Facing
@onready var hand: Marker2D = $Facing/Hand
@onready var pickup_sensor: Area2D = $PickupSensor
@onready var foot_sensor: Area2D = $FootSensor
@onready var body_collision: CollisionShape2D = $CollisionShape2D

var health: int = 3
var facing: float = 1.0
var held_object: ThrowableObject
var invulnerability: float = 0.0
var dead: bool = false
var celebrating: bool = false
var crouching: bool = false
var motion_state: StringName = &"idle"
var _coyote: float = 0.0
var _buffer: float = 0.0
var _jump_cut_allowed: bool = false
var _action: StringName = &""
var _action_time: float = 0.0
var _pending_object: ThrowableObject
var _release_done: bool = false
var _defeat_notified: bool = false
var _landing: float = 0.0
var _visual_scales: Dictionary = {}
var _standing_shape: CapsuleShape2D
var _crouching_shape: CapsuleShape2D
var _standing_body_position: Vector2
var _standing_hand_position: Vector2
var _standing_pickup_position: Vector2


func _ready() -> void:
	health = maximum_health
	# Cada instancia conserva sus propias formas; el recurso de la escena no se modifica.
	_standing_shape = body_collision.shape.duplicate() as CapsuleShape2D
	_crouching_shape = _standing_shape.duplicate() as CapsuleShape2D
	_crouching_shape.height = clampf(tuning.crouch_height, _standing_shape.radius * 2.0, _standing_shape.height)
	body_collision.shape = _standing_shape
	_standing_body_position = body_collision.position
	_standing_hand_position = hand.position
	_standing_pickup_position = pickup_sensor.position
	_visual_scales = JSON.parse_string(FileAccess.get_file_as_string(
		"res://game/features/player/animation_scales.json"))
	sprite.frame_changed.connect(_animation_marker)
	_play(&"idle")


func _physics_process(delta: float) -> void:
	invulnerability = maxf(0.0, invulnerability - delta)
	_landing = maxf(0.0, _landing - delta)
	queue_redraw()
	if celebrating:
		if crouching and can_stand():
			_set_crouching(false)
		velocity.x = 0.0
		_apply_gravity(delta)
		move_and_slide()
		return
	if dead:
		_apply_gravity(delta)
		move_and_slide()
		_action_time += delta
		if _action_time >= 0.9 and not _defeat_notified:
			_defeat_notified = true
			defeated.emit()
		return

	var was_grounded: bool = is_on_floor()
	var previous_feet: Vector2 = global_position
	_update_crouch(was_grounded)
	if was_grounded:
		_coyote = tuning.coyote_seconds
	else:
		_coyote = maxf(0.0, _coyote - delta)
	_buffer = maxf(0.0, _buffer - delta)
	if controls.consume(&"jump"):
		_buffer = tuning.jump_buffer_seconds
	if crouching:
		# Mantener abajo no acumula saltos para cuando se suelte el gesto.
		_buffer = 0.0
	var axis: float = controls.horizontal()
	if _action.is_empty():
		if not is_zero_approx(axis):
			facing = signf(axis)
		facing_node.scale.x = facing
		var speed: float = tuning.run_speed if controls.automatic_run or controls.held(&"run") else tuning.walk_speed
		if is_instance_valid(held_object):
			speed *= 0.82
		if crouching:
			speed = 0.0
		var acceleration: float = tuning.acceleration if was_grounded else tuning.air_acceleration
		if is_zero_approx(axis) or crouching:
			acceleration = tuning.braking if was_grounded else tuning.air_acceleration
		velocity.x = move_toward(velocity.x, axis * speed, acceleration * delta)
		if _buffer > 0.0 and _coyote > 0.0:
			velocity.y = -tuning.jump_speed
			_buffer = 0.0
			_coyote = 0.0
			_jump_cut_allowed = true
			_landing = 0.0
			jumped.emit()
		if controls.consume(&"grab_throw") and not crouching:
			_interact()
	else:
		controls.consume(&"grab_throw")
		if _action != &"hurt":
			velocity.x = move_toward(velocity.x, 0.0, tuning.braking * delta)
		_action_time += delta
		if _action_time >= _action_duration():
			_action = &""
			_pending_object = null

	if _jump_cut_allowed and velocity.y < 0.0 and not controls.held(&"jump") and not controls.full_jump:
		velocity.y *= tuning.short_jump_factor
		_jump_cut_allowed = false
	_apply_gravity(delta)
	var falling_speed: float = velocity.y
	move_and_slide()
	for area in foot_sensor.get_overlapping_areas():
		if area is StompTarget and area.receive_stomp(self, previous_feet, falling_speed):
			velocity.y = -tuning.stomp_bounce
			_jump_cut_allowed = false
			_coyote = 0.0
			bounced.emit()
			break
	if is_on_floor() and not was_grounded and falling_speed > 160.0:
		_landing = 0.10
	if is_on_ceiling():
		_jump_cut_allowed = false
	_update_animation()
	if global_position.y > fall_limit_y:
		_die()


func _apply_gravity(delta: float) -> void:
	velocity.y = minf(velocity.y + tuning.gravity * delta, tuning.maximum_fall_speed)


func _update_crouch(grounded: bool) -> void:
	if grounded and controls.held(&"crouch") and _action.is_empty():
		_set_crouching(true)
	elif crouching and can_stand():
		_set_crouching(false)


func can_stand() -> bool:
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = _standing_shape
	# Separar la consulta del contacto con el suelo; conservar un pequeño margen arriba.
	query.transform = global_transform * Transform2D(0.0, _standing_body_position - Vector2(0.0, safe_margin + 0.1))
	query.collision_mask = collision_mask
	query.exclude = [get_rid()]
	return get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()


func _set_crouching(value: bool) -> void:
	if crouching == value:
		return
	crouching = value
	body_collision.shape = _crouching_shape if value else _standing_shape
	# La base de la cápsula y el sensor de pisotón permanecen a la altura de los pies.
	body_collision.position = Vector2(_standing_body_position.x, -_crouching_shape.height / 2.0) if value else _standing_body_position
	var hand_drop: float = (_standing_shape.height - _crouching_shape.height) * 0.7 if value else 0.0
	hand.position = _standing_hand_position + Vector2(0.0, hand_drop)
	pickup_sensor.position = _standing_pickup_position + Vector2(0.0, hand_drop)


func _interact() -> void:
	_release_done = false
	if is_instance_valid(held_object):
		_begin_action(&"throw")
		return
	var nearest: ThrowableObject
	var nearest_distance: float = INF
	for body in pickup_sensor.get_overlapping_bodies():
		if body is ThrowableObject and body.can_be_picked_up():
			var distance: float = global_position.distance_squared_to(body.global_position)
			var ray := PhysicsRayQueryParameters2D.create(hand.global_position, body.global_position, 1)
			if distance < nearest_distance and get_world_2d().direct_space_state.intersect_ray(ray).is_empty():
				nearest = body
				nearest_distance = distance
	if is_instance_valid(nearest):
		_pending_object = nearest
		_begin_action(&"grab")


func _begin_action(action: StringName) -> void:
	_action = action
	_action_time = 0.0
	_play(&"crouch" if crouching and action == &"hurt" else action)
	sprite.set_frame_and_progress(0, 0.0)
	sprite.play()


func _animation_marker() -> void:
	if sprite.frame != 2 or _release_done:
		return
	if _action == &"grab" and is_instance_valid(_pending_object):
		if _pending_object.can_be_picked_up() and global_position.distance_to(_pending_object.global_position) < 105.0:
			held_object = _pending_object
			held_object.pick_up(hand)
		_release_done = true
	elif _action == &"throw" and is_instance_valid(held_object):
		held_object.release(facing, velocity)
		held_object = null
		_release_done = true
		object_released.emit()


func _action_duration() -> float:
	return 0.4 if _action == &"hurt" else 4.0 / 12.0


func _update_animation() -> void:
	if crouching:
		_play(&"crouch")
	elif not _action.is_empty():
		_play(_action)
	elif not is_on_floor():
		if is_instance_valid(held_object):
			_play(&"carry_idle")
		else:
			_play(&"jump_up" if velocity.y < -50.0 else &"fall")
	elif _landing > 0.0 and not is_instance_valid(held_object):
		_play(&"land")
	elif absf(velocity.x) < 12.0:
		_play(&"carry_idle" if is_instance_valid(held_object) else &"idle")
	elif is_instance_valid(held_object):
		_play(&"carry_run")
	else:
		_play(&"run" if absf(velocity.x) > tuning.walk_speed + 12.0 else &"walk")


func _play(animation: StringName) -> void:
	if sprite.animation == animation and sprite.is_playing():
		return
	# No reiniciar acciones de un solo uso una vez terminadas.
	if sprite.animation == animation and not sprite.sprite_frames.get_animation_loop(animation):
		return
	sprite.scale = Vector2.ONE * float(_visual_scales.get(String(animation), 0.19))
	sprite.play(animation)
	if motion_state != animation:
		motion_state = animation
		state_changed.emit(animation)


func take_damage(source: Vector2) -> bool:
	if invulnerability > 0.0 or dead or celebrating:
		return false
	health -= 1
	health_changed.emit(health)
	_drop_object()
	if health <= 0:
		_die()
	else:
		invulnerability = tuning.invulnerability_seconds
		velocity = Vector2(-230.0 if source.x >= global_position.x else 230.0, -280.0)
		_begin_action(&"hurt")
	return true


func _drop_object() -> void:
	if is_instance_valid(held_object):
		held_object.release(facing, Vector2.ZERO, false)
		held_object = null
	_pending_object = null


func _die() -> void:
	if dead:
		return
	dead = true
	health = 0
	velocity.x = 0.0
	controls.clear_virtual()
	_drop_object()
	_begin_action(&"defeated")
	health_changed.emit(health)


func celebrate() -> void:
	if dead or celebrating:
		return
	celebrating = true
	_drop_object()
	controls.clear_virtual()
	_begin_action(&"victory")


func recover_energy() -> void:
	if dead or celebrating:
		return
	health = maximum_health
	health_changed.emit(health)


func respawn(at: Vector2) -> void:
	_drop_object()
	_set_crouching(false)
	global_position = at
	velocity = Vector2.ZERO
	health = maximum_health
	dead = false
	celebrating = false
	invulnerability = 0.0
	_coyote = 0.0
	_buffer = 0.0
	_landing = 0.0
	_action = &""
	_action_time = 0.0
	_jump_cut_allowed = false
	_defeat_notified = false
	controls.clear_virtual()
	controls.enabled = true
	_play(&"idle")
	health_changed.emit(health)


func suspend_controls() -> void:
	controls.enabled = false
	controls.clear_virtual()
	_buffer = 0.0


func _draw() -> void:
	# Protección continua y visible: sin parpadeos ni destellos.
	if invulnerability > 0.0:
		draw_arc(Vector2(0, -52), 62.0, 0.0, TAU, 48, Color("ffe4a8"), 3.0, true)


