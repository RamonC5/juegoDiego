class_name ForestSwingingVine
extends Node2D
## Liana de péndulo oscilante. Sin colisión sólida: el agarre se decide
## por proximidad física de las manos y no bloquea el movimiento normal.

const LENGTH: float = 335.0
const SWING_AMPLITUDE: float = 0.49
const SWING_SPEED: float = 1.62
const HAND_REACH: float = 70.0
const TEXTURE: Texture2D = preload("res://game/assets/textures/environments/bosque_esmeralda/mechanisms/swinging_vine_v001.png")

var phase_offset: float = 0.0
## Las lianas de barranco conservan sus medidas; el acceso al dosel es más largo.
var length: float = LENGTH
var swing_amplitude: float = SWING_AMPLITUDE
var elapsed: float = 0.0
var angle: float = 0.0
var _lean: float = 0.0
var _lean_velocity: float = 0.0
var previous_grip: Vector2 = Vector2.ZERO
var grip_velocity: Vector2 = Vector2.ZERO
var _last_grip: Vector2 = Vector2.ZERO


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	var alpha := ShaderMaterial.new()
	alpha.shader = preload("res://game/features/levels/mechanisms/forest_asset_alpha.gdshader")
	material = alpha
	process_physics_priority = -12
	angle = swing_amplitude * sin(phase_offset)
	_last_grip = grip_global_position()
	previous_grip = _last_grip
	queue_redraw()


func _physics_process(delta: float) -> void:
	elapsed += delta
	# Resorte amortiguado: el arrastre aporta impulso y se libera gradualmente.
	_lean_velocity += (-_lean * 4.0 - _lean_velocity * 1.4) * delta
	_lean = clampf(_lean + _lean_velocity * delta, -0.17, 0.17)
	angle = swing_amplitude * sin(elapsed * SWING_SPEED + phase_offset) + _lean
	var next_grip: Vector2 = grip_global_position()
	previous_grip = _last_grip
	grip_velocity = (next_grip - _last_grip) / maxf(delta, 0.001)
	_last_grip = next_grip
	queue_redraw()


func push(axis: float, delta: float) -> void:
	# El jugador puede ampliar levemente el alcance del balanceo moviéndose.
	_lean_velocity = clampf(_lean_velocity + axis * delta * 0.90, -0.40, 0.40)


func grip_global_position(climb_distance: float = 0.0) -> Vector2:
	return to_global(Vector2(sin(angle), cos(angle)) * (length - clampf(climb_distance, 0.0, length)))


func velocity_at(climb_distance: float) -> Vector2:
	return grip_velocity * (1.0 - clampf(climb_distance / length, 0.0, 1.0))


func reset_cycle() -> void:
	elapsed = 0.0
	_lean = 0.0
	_lean_velocity = 0.0
	angle = swing_amplitude * sin(phase_offset)
	grip_velocity = Vector2.ZERO
	_last_grip = grip_global_position()
	previous_grip = _last_grip
	queue_redraw()


func _draw() -> void:
	# Una cuerda raster con hojas y nudo orgánico conserva el acabado del bosque.
	draw_set_transform(Vector2.ZERO, -angle)
	var source := Rect2(TEXTURE.get_size() * Vector2(0.30, 0), TEXTURE.get_size() * Vector2(0.40, 1.0))
	draw_texture_rect_region(TEXTURE, Rect2(-40, -8, 80, length + 30), source)
	draw_set_transform(Vector2.ZERO)


