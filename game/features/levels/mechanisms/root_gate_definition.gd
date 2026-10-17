class_name ForestRootGateDefinition
extends Resource
## Dos estaciones accesibles desde la misma orilla; no se cierra tras pasar.

@export var gate_id: StringName
@export var display_name: String
@export var position: Vector2
@export var stations: Array[RootBridgeDefinition] = []
