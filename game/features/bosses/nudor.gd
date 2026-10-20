class_name NudorBoss
extends StaticBody2D
## La física decide las ventanas; el raster articulado solo presenta el estado.

signal health_changed(remaining: int, maximum: int)
signal state_changed(next: State)
signal defeated

enum State { WAITING, INTRO, SLAM_WARNING, SLAM, SWEEP_WARNING, SWEEP, OPEN, HURT, DEFEATED }

@export var maximum_health: int = 5
@export var warning_seconds: float = 1.6
@export var opening_seconds: float = 3.5
var health: int = 5
var state: State = State.WAITING
var hero: DiegoPlayer
var arena_left: float = 100.0
var arena_right: float = 1180.0
var state_seconds: float = 0.0
var cycles: int = 0
var slam_x: float = 0.0
var sweep_x: float = 0.0
var visual: NudorVisual
var _attack_slam: bool = true
var _hit_in_opening: bool = false
var _victory_emitted: bool = false
var _accepted_launches: Dictionary = {}
var _attack_art: Sprite2D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	# Capa receptora de arrojadizos: no es suelo ni un StompTarget.
	collision_layer = 64
	collision_mask = 0
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(170, 230)
	collider.shape = shape
	collider.position = Vector2(0, -150)
	add_child(collider)
	visual = NudorVisual.new()
	add_child(visual)
	_attack_art = Sprite2D.new()
	var root_texture := AtlasTexture.new()
	root_texture.atlas = RootBridge.TEXTURE
	root_texture.region = Rect2(RootBridge.TEXTURE.get_size() * Vector2(0.007, 0.26), RootBridge.TEXTURE.get_size() * Vector2(0.987, 0.52))
	_attack_art.texture = root_texture
	var root_material := ShaderMaterial.new()
	root_material.shader = preload("res://game/features/player/sprite_alpha.gdshader")
	_attack_art.material = root_material
	_attack_art.hide()
	add_child(_attack_art)
	reset_encounter()


func reset_encounter() -> void:
	health = maximum_health
	cycles = 0
	_hit_in_opening = false
	_victory_emitted = false
	_accepted_launches.clear()
	_attack_slam = true
	_attack_art.hide()
	visual.reset_pose()
	_enter(State.WAITING)
	health_changed.emit(health, maximum_health)


func begin_encounter() -> void:
	if state == State.WAITING:
		_enter(State.INTRO)


func _enter(next: State) -> void:
	state = next
	state_seconds = 0.0
	if next == State.SLAM_WARNING:
		# Fija el destino desde el aviso: nunca sigue a Diego al final del golpe.
		slam_x = clampf(hero.global_position.x, arena_left + 105, arena_right - 170) if is_instance_valid(hero) else arena_left + 300
	if next == State.SWEEP:
		sweep_x = global_position.x - 100.0
	if next == State.OPEN:
		_hit_in_opening = false
	state_changed.emit(next)


func _begin_attack() -> void:
	# Primero enseña ambos por separado; después alterna con los mismos avisos.
	_attack_slam = cycles % 2 == 0
	_enter(State.SLAM_WARNING if _attack_slam else State.SWEEP_WARNING)


func receive_thrown_hit(object: ThrowableObject) -> void:
	if state != State.OPEN or _hit_in_opening or not is_instance_valid(object) or not object.can_cause_thrown_damage():
		return
	# Solo la bellota abierta recibe daño. El resto de la corteza consume el tiro.
	var relative: Vector2 = object.global_position - global_position
	if absf(relative.x) > 112.0 or relative.y < -245.0 or relative.y > -130.0:
		return
	var launch_id: String = "%d:%d" % [object.get_instance_id(), object.launch_serial]
	if _accepted_launches.has(launch_id):
		return
	_accepted_launches[launch_id] = true
	_hit_in_opening = true
	health = maxi(0, health - 1)
	health_changed.emit(health, maximum_health)
	if health == 0:
		_enter(State.DEFEATED)
		if not _victory_emitted:
			_victory_emitted = true
			defeated.emit()
	else:
		_enter(State.HURT)


func attack_bounds() -> Rect2:
	if state == State.SLAM or state == State.SLAM_WARNING:
		return Rect2(slam_x - 85.0, global_position.y - 120.0, 170.0, 120.0)
	if state == State.SWEEP:
		return Rect2(sweep_x - 80.0, global_position.y - 55.0, 160.0, 55.0)
	return Rect2()


func _physics_process(delta: float) -> void:
	if not is_instance_valid(hero) or hero.dead:
		return
	state_seconds += delta
	match state:
		State.INTRO:
			if state_seconds >= 1.8:
				_begin_attack()
		State.SLAM_WARNING, State.SWEEP_WARNING:
			if state_seconds >= warning_seconds:
				_enter(State.SLAM if state == State.SLAM_WARNING else State.SWEEP)
		State.SLAM:
			if state_seconds >= 0.48:
				_enter(State.OPEN)
		State.SWEEP:
			sweep_x = move_toward(sweep_x, arena_left + 80.0, delta * 440.0)
			if sweep_x <= arena_left + 80.0:
				_enter(State.OPEN)
		State.OPEN:
			if state_seconds >= opening_seconds:
				cycles += 1
				_begin_attack()
		State.HURT:
			if state_seconds >= 1.0:
				cycles += 1
				_begin_attack()
	visual.advance_pose(delta, state, state_seconds, warning_seconds)
	var bounds: Rect2 = attack_bounds()
	_attack_art.visible = bounds.has_area()
	if bounds.has_area():
		var art_height: float = 18.0 if state == State.SLAM_WARNING else bounds.size.y
		_attack_art.global_position = Vector2(bounds.get_center().x, global_position.y - art_height / 2.0)
		_attack_art.scale = Vector2(bounds.size.x / _attack_art.texture.get_width(), art_height / _attack_art.texture.get_height())
		_attack_art.modulate.a = 0.42 if state == State.SLAM_WARNING else 1.0
	# Aviso, entrada, recuperación y victoria nunca causan daño.
	if state in [State.SLAM, State.SWEEP]:
		var body := Rect2(hero.global_position - Vector2(20, 82), Vector2(40, 82))
		if bounds.intersects(body):
			hero.take_damage(Vector2(bounds.get_center().x, global_position.y))
	if state not in [State.WAITING, State.INTRO, State.DEFEATED]:
		var trunk := Rect2(global_position + Vector2(-88, -260), Vector2(176, 260))
		if trunk.has_point(hero.global_position - Vector2(0, 35)):
			hero.take_damage(global_position)
