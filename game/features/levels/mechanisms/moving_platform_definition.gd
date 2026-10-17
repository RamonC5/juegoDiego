class_name MovingPlatformDefinition
extends Resource
## Extremos del recorrido medidos en el centro de la superficie de apoyo.

@export var platform_id: StringName
@export var display_name: String = "Tronco viajero"
@export var start_position: Vector2
@export var end_position: Vector2
@export_range(120.0, 360.0, 1.0) var width: float = 240.0
@export_range(1.0, 8.0, 0.1) var travel_seconds: float = 3.0
@export_range(0.5, 3.0, 0.1) var stop_seconds: float = 1.5
@export var tutorial: bool = false
