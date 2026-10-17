class_name ForestSwingingVine
extends Node2D
## Liana de péndulo oscilante. Sin colisión sólida: el agarre se decide
## por proximidad física de las manos y no bloquea el movimiento normal.

const LENGTH: float = 335.0
const SWING_AMPLITUDE: float = 0.49
const SWING_SPEED: float = 1.62
const HAND_REACH: float = 119.0

var phase_offset: float = 0.0
var elapsed: float = 0.0
var angle: float = 0.0
var _lean: float = 0.0
var grip_velocity: Vector2 = Vector2.ZERO
var _last_grip: Vector2 = Vector2.ZERO


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	process_physics_priority = -12
	angle = SWING_AMPLITUDE * sin(phase_offset)
	_last_grip = grip_global_position()
	queue_redraw()


func _physics_process(delta: float) -> void:
	elapsed += delta
	_lean = move_toward(_lean, 0.0, delta * 0.22)
	angle = SWING_AMPLITUDE * sin(elapsed * SWING_SPEED + phase_offset) + _lean
	var next_grip: Vector2 = grip_global_position()
	grip_velocity = (next_grip - _last_grip) / maxf(delta, 0.001)
	_last_grip = next_grip
	queue_redraw()


func push(axis: float, delta: float) -> void:
	# El jugador puede ampliar levemente el alcance del balanceo moviéndose.
	_lean = clampf(_lean + axis * delta * 0.18, -0.12, 0.12)


func grip_global_position() -> Vector2:
	return to_global(Vector2(sin(angle), cos(angle)) * LENGTH)


func reset_cycle() -> void:
	elapsed = 0.0
	_lean = 0.0
	angle = SWING_AMPLITUDE * sin(phase_offset)
	grip_velocity = Vector2.ZERO
	_last_grip = grip_global_position()
	queue_redraw()


func _draw() -> void:
	var tip := Vector2(sin(angle), cos(angle)) * LENGTH
	var normal := Vector2(cos(angle), -sin(angle))
	# Cuerda curva en lugar de una barra rígida; hojas fijadas al tallo.
	var points := PackedVector2Array()
	for i in 13:
		var fraction: float = float(i) / 12.0
		points.append(tip * fraction + normal * (sin(fraction * PI) * 11.0))
	draw_polyline(points, Color("314a2a"), 15.0, true)
	draw_polyline(points, Color("8bb668"), 5.0, true)
	draw_circle(Vector2.ZERO, 17.0, Color("596c3b"))
	for i in 6:
		var fraction: float = 0.16 + float(i) * 0.132
		var mid: Vector2 = tip * fraction + normal * (sin(fraction * PI) * 11.0)
		var side: float = -1.0 if i % 2 == 0 else 1.0
		draw_line(mid, mid + normal * side * 27.0 + Vector2(0, -12), Color("527b42"), 6.0, true)
		draw_circle(mid + normal * side * 27.0 + Vector2(0, -12), 12.0, Color("91b772"))
	# Zona visible de agarre: gran nudo con dos hojas, no hay UI ni texto.
	draw_circle(tip, 20.0, Color("45542d"))
	draw_circle(tip, 12.0, Color("b5d884"))
	draw_arc(tip, 20.0, 0.0, TAU, 26, Color("ebdda4"), 3.0, true)
