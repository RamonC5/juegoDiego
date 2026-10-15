class_name StompTarget
extends Area2D
## El enemigo conecta stomped a su comportamiento; la imagen no decide el daño.

signal stomped(player: Node2D)

@export var enabled: bool = true
@export var half_width: float = 36.0
@export var top_tolerance: float = 10.0


func receive_stomp(player: Node2D, previous_feet: Vector2, falling_speed: float) -> bool:
	if not enabled or falling_speed <= 0.0:
		return false
	if previous_feet.y > global_position.y + top_tolerance:
		return false
	if absf(player.global_position.x - global_position.x) > half_width + 15.0:
		return false
	enabled = false
	stomped.emit(player)
	return true
