class_name ForestLevelDefinition
extends Resource
## Datos editables del nivel; los identificadores no dependen del título visible.

@export var level_id: String = "world_01_level_01"
@export var world_id: String = "world_01"
@export var display_name: String = "Bosque Esmeralda"
@export var subtitle: String = "El despertar del bosque"
@export var width: float = 8200.0
@export var spawn: Vector2 = Vector2(180, 600)
@export var checkpoint: Vector2 = Vector2(4160, 600)
@export var goal: Vector2 = Vector2(7900, 600)
@export var ground_sections: Array[Rect2] = []
@export var raised_platforms: Array[Rect2] = []
## x, y, límite izquierdo y límite derecho de cada patrulla.
@export var enemy_spawns: Array[Vector4] = []
@export var enemy_kinds: PackedStringArray = []
## x, y e índice del catálogo de arrojadizos.
@export var object_spawns: Array[Vector3] = []
@export var crystal_positions: Array[Vector2] = []
## Exactamente tres llaves por intento. El arte se elige por entorno, no por color.
@export var key_definition: LevelKeyDefinition
@export var key_positions: Array[Vector2] = []

