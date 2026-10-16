class_name RootBridgeDefinition
extends Resource
## Datos de una estación: el dibujo, el impacto y la recuperación no fijan coordenadas globales.

@export var mechanism_id: StringName
@export var display_name: String = "Puente de raíces"
@export var bridge_rect: Rect2 = Rect2(0, 600, 420, 78)
@export var target_position: Vector2
@export var pine_position: Vector2
@export var recovery_bounds: Rect2
@export var tutorial: bool = false
