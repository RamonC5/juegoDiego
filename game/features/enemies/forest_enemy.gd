class_name ForestEnemy
extends CharacterBody2D
## Patrulla y combate separados de la animación articulada del raster 2D.

signal defeated(enemy: ForestEnemy, by_throw: bool)

const SPRITES: Dictionary = {
	"terron": preload("res://game/assets/textures/characters/terron/idle_v001.png"),
	"moflete": preload("res://game/assets/textures/characters/moflete/idle_v001.png"),
}

var spawn_index: int = -1
var kind: String = "terron"
var patrol: Vector2 = Vector2(0, 200)
var player: DiegoPlayer
var active: bool = true
var _direction: float = -1.0
var _visual: EnemyVisual
var _scale: float = 1.0
var _height: float = 58.0
var _stomp: StompTarget
var _contact: Area2D
enum Behaviour { PATROL, NOTICE, CHASE, RETURN }
var behaviour: Behaviour = Behaviour.PATROL
## El origen elevado limita la patrulla; la persecución permite descender.
var platform_guard: bool = false
var movement_bounds: Vector2 = Vector2(-1000000, 1000000)
var _home: Vector2
var _notice_seconds: float = 0.0
var _lost_seconds: float = 0.0
var _last_seen_x: float = 0.0
var _half_width: float = 52.0
var pursuit_bounds: Vector2 = Vector2(-1000000, 1000000)
var _has_pursued: bool = false
var _return_x: float = 0.0
var _roaming_patrol: Vector2
var _last_floor_y: float = 0.0
var _last_seen_y: float = 0.0
var _drop_direction: float = 0.0
var _support_span: Vector2
var _support_rid: RID


func _ready() -> void:
	_home = position
	_return_x = _home.x
	_last_floor_y = _home.y
	_roaming_patrol = patrol
	_half_width = 24.0 if kind == "moflete" else 52.0
	collision_layer = 4
	collision_mask = 1
	_height = 76.0 if kind == "moflete" else 52.0
	var body := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(48 if kind == "moflete" else 104, _height)
	body.shape = rectangle
	body.position.y = -_height / 2.0
	add_child(body)
	_visual = EnemyVisual.new()
	_visual.configure(kind, SPRITES[kind])
	var atlas := _visual.texture as AtlasTexture
	_scale = (_height + 8.0) / atlas.region.size.y
	_visual.scale = Vector2.ONE * _scale
	_visual.phase = fposmod(position.x * 0.017, TAU)
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
func has_visible_art() -> bool:
	if not is_instance_valid(_visual) or not _visual.is_visible_in_tree():
		return false
	var atlas := _visual.texture as AtlasTexture
	return atlas != null and atlas.atlas != null and atlas.region.has_area()


func _physics_process(delta: float) -> void:
	if not active:
		return
	# Solo la zona cercana necesita simulación de enemigos, también al volver atrás.
	if is_instance_valid(player) and absf(player.position.x - position.x) > 2200.0:
		if behaviour != Behaviour.PATROL:
			reset_awareness()
		return
	var sees_player: bool = can_see_player()
	if not is_instance_valid(player) or player.dead or player.celebrating:
		if behaviour != Behaviour.PATROL:
			behaviour = Behaviour.RETURN
	elif sees_player:
		_last_seen_x = player.position.x
		_last_seen_y = player.position.y
		_lost_seconds = 0.0
		if behaviour == Behaviour.PATROL or behaviour == Behaviour.RETURN:
			behaviour = Behaviour.NOTICE
			_notice_seconds = 0.42
	elif behaviour == Behaviour.CHASE:
		_lost_seconds += delta
		var search_seconds: float = 3.5 if _last_seen_y > position.y + 32.0 else 1.3
		if _lost_seconds > search_seconds or absf(position.x - _home.x) > 950.0:
			behaviour = Behaviour.RETURN
	var speed: float = 58.0 if kind == "moflete" else 43.0
	match behaviour:
		Behaviour.NOTICE:
			_notice_seconds = maxf(0.0, _notice_seconds - delta)
			_direction = signf(_last_seen_x - position.x)
			speed = 0.0
			if _notice_seconds <= 0.0:
				behaviour = Behaviour.CHASE
		Behaviour.CHASE:
			_has_pursued = true
			_direction = _chase_direction()
			speed = 142.0 if kind == "moflete" else 112.0
		Behaviour.RETURN:
			_direction = signf(_return_x - position.x)
			if absf(position.x - _return_x) < 12.0:
				behaviour = Behaviour.PATROL
				_direction = 1.0 if is_zero_approx(_direction) else _direction
		Behaviour.PATROL:
			if position.x <= _roaming_patrol.x:
				_direction = 1.0
			elif position.x >= _roaming_patrol.y:
				_direction = -1.0
	if not _can_step(_direction, speed * delta):
		if behaviour == Behaviour.PATROL:
			_direction *= -1.0
		else:
			speed = 0.0
	# Acelerar y frenar antes de correr evita cambios instantáneos de velocidad.
	var acceleration: float = 600.0 if behaviour == Behaviour.CHASE else 380.0
	velocity.x = move_toward(velocity.x, _direction * speed, acceleration * delta)
	if not _can_step(signf(velocity.x), absf(velocity.x) * delta):
		velocity.x = 0.0
	velocity.y = minf(velocity.y + 1700.0 * delta, 900.0)
	move_and_slide()
	_update_support()
	var bounds: Vector2 = pursuit_bounds if _has_pursued else movement_bounds
	position.x = clampf(position.x, bounds.x, bounds.y)
	if is_on_floor() and position.y > _last_floor_y + 32.0:
		# Tras bajar, regresar y patrullar desde el nuevo suelo, sin intentar subir ni teletransportarse.
		_return_x = position.x
		_roaming_patrol = Vector2(position.x - 120.0, position.x + 120.0)
		_drop_direction = 0.0
	if is_on_floor():
		_last_floor_y = position.y
	if is_on_wall() and behaviour == Behaviour.PATROL:
		_direction *= -1.0
	_visual.face_left(velocity.x < 0.0 if absf(velocity.x) > 5.0 else _direction < 0.0)
	_visual.advance(delta, get_real_velocity().x, is_on_floor(), behaviour == Behaviour.NOTICE or behaviour == Behaviour.CHASE)
	if is_instance_valid(player) and not player.dead and _contact.overlaps_body(player):
		if player.global_position.y > global_position.y - _height + 16.0:
			player.take_damage(global_position)


func can_see_player() -> bool:
	if not is_instance_valid(player) or player.dead or player.celebrating:
		return false
	var difference: Vector2 = player.global_position - global_position
	var distance: float = 540.0 if kind == "moflete" else 460.0
	if absf(difference.x) > distance or difference.y < -160.0 or difference.y > 440.0:
		return false
	if absf(player.position.x - _home.x) > 950.0:
		return false
	var query := PhysicsRayQueryParameters2D.create(global_position - Vector2(0, _height * 0.6), player.global_position - Vector2(0, 52), 1)
	query.exclude = [get_rid()]
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()


func _can_step(direction: float, advance: float) -> bool:
	if is_zero_approx(direction):
		return true
	var next_x: float = position.x + direction * advance
	var bounds: Vector2 = pursuit_bounds if _has_pursued else movement_bounds
	if next_x < bounds.x or next_x > bounds.y:
		return false
	if not is_on_floor():
		return true
	var probe := global_position + Vector2(direction * (_half_width + advance + 10.0), -12.0)
	var query := PhysicsRayQueryParameters2D.create(probe, probe + Vector2(0, 55), 1)
	query.exclude = [get_rid()]
	if not get_world_2d().direct_space_state.intersect_ray(query).is_empty():
		return true
	if behaviour != Behaviour.CHASE or _last_seen_y < position.y - 24.0:
		return false
	return _has_lower_landing(direction, advance)


func _has_lower_landing(direction: float, advance: float) -> bool:
	if not _support_rid.is_valid():
		return false
	# El centro debe superar todo el borde antes de caer. El apoyo actual no cuenta
	# como aterrizaje; así se admiten terrazas estrechas sin confundirlas con un vacío.
	var landing_x: float = _support_span.y + _half_width + advance + 2.0 if direction > 0.0 else _support_span.x - _half_width - advance - 2.0
	if landing_x < pursuit_bounds.x or landing_x > pursuit_bounds.y:
		return false
	var from := Vector2(landing_x, global_position.y - 12.0)
	var query := PhysicsRayQueryParameters2D.create(from, from + Vector2(0, 720), 1)
	query.exclude = [get_rid(), _support_rid]
	return not get_world_2d().direct_space_state.intersect_ray(query).is_empty()


func _update_support() -> void:
	if not is_on_floor():
		return
	for index in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(index)
		if collision.get_normal().y > -0.7:
			continue
		var collider := collision.get_collider() as CollisionObject2D
		if collider == null:
			continue
		var shape_owner: int = collider.shape_find_owner(collision.get_collider_shape_index())
		var shape_node := collider.shape_owner_get_owner(shape_owner) as CollisionShape2D
		if shape_node == null or not shape_node.shape is RectangleShape2D:
			continue
		var rectangle := shape_node.shape as RectangleShape2D
		var rect: Rect2 = shape_node.global_transform * Rect2(-rectangle.size / 2.0, rectangle.size)
		if _support_rid != collider.get_rid():
			_drop_direction = 0.0
		_support_rid = collider.get_rid()
		_support_span = Vector2(rect.position.x, rect.end.x)
		return


func _chase_direction() -> float:
	if not is_on_floor() and not is_zero_approx(_drop_direction):
		return _drop_direction
	if _last_seen_y > position.y + 32.0 and _support_rid.is_valid():
		if is_zero_approx(_drop_direction):
			if _last_seen_x < _support_span.x:
				_drop_direction = -1.0
			elif _last_seen_x > _support_span.y:
				_drop_direction = 1.0
			else:
				_drop_direction = -1.0 if position.x - _support_span.x < _support_span.y - position.x else 1.0
			if not _has_lower_landing(_drop_direction, 3.0) and _has_lower_landing(-_drop_direction, 3.0):
				_drop_direction *= -1.0
		return _drop_direction
	return signf(_last_seen_x - position.x)


func reset_awareness() -> void:
	behaviour = Behaviour.PATROL
	position = _home
	velocity = Vector2.ZERO
	_has_pursued = false
	_support_rid = RID()
	_support_span = Vector2.ZERO
	_return_x = _home.x
	_last_floor_y = _home.y
	_roaming_patrol = patrol
	_drop_direction = 0.0
	_notice_seconds = 0.0
	_lost_seconds = 0.0


func receive_thrown_hit(object: ThrowableObject) -> void:
	if active and object.can_cause_thrown_damage():
		defeat(true)


func defeat(by_throw: bool) -> void:
	if not active:
		return
	active = false
	_stomp.enabled = false
	set_deferred("collision_layer", 0)
	_contact.set_deferred("monitoring", false)
	defeated.emit(self, by_throw)
	var tween := create_tween()
	tween.tween_property(_visual, "scale", Vector2(1.35, 0.2) * _scale, 0.14)
	tween.tween_interval(0.22)
	tween.tween_property(_visual, "modulate:a", 0.0, 0.25)
	tween.tween_callback(queue_free)



