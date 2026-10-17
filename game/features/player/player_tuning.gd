class_name PlayerTuning
extends Resource
## Valores de partida editables, en píxeles lógicos y segundos.

@export var walk_speed: float = 210.0
@export var run_speed: float = 330.0
@export var crouch_speed: float = 90.0
@export var acceleration: float = 1900.0
@export var braking: float = 2400.0
@export var air_acceleration: float = 1100.0
@export var gravity: float = 1700.0
@export var maximum_fall_speed: float = 900.0
@export var jump_speed: float = 680.0
@export var air_jump_speed: float = 590.0
@export var short_jump_factor: float = 0.45
@export var coyote_seconds: float = 0.12
@export var jump_buffer_seconds: float = 0.14
@export var stomp_bounce: float = 470.0
@export var invulnerability_seconds: float = 1.2
@export_range(38.0, 96.0, 1.0) var crouch_height: float = 58.0

