class_name ForestLevelDefinition
extends Resource
## Datos editables del nivel; los identificadores no dependen del título visible.

@export var level_id: String = "world_01_level_01"
@export var world_id: String = "world_01"
@export var display_name: String = "Bosque Esmeralda"
@export var music_stream: AudioStream
@export var subtitle: String = "El despertar del bosque"
@export var width: float = 8200.0
@export var spawn: Vector2 = Vector2(180, 600)
@export var checkpoint: Vector2 = Vector2(4160, 600)
## Exactamente tres puntos por nivel; activarlos conserva las vidas actuales.
## Orden de avance: volver a un farol anterior no hace retroceder la reaparición.
@export var checkpoints: Array[Vector2] = []
@export var goal: Vector2 = Vector2(7900, 600)
@export var ground_sections: Array[Rect2] = []
@export var raised_platforms: Array[Rect2] = []
@export var recovery_platforms: Array[Rect2] = []
@export var bridges: Array[RootBridgeDefinition] = []
@export var moving_platforms: Array[MovingPlatformDefinition] = []
@export var root_gates: Array[ForestRootGateDefinition] = []
## Orígenes de pasos de liana y dianas rebotadoras sobre barrancos.
@export var vine_crossings: Array[Vector2] = []
## Centro de la trampilla opcional (x, altura de la superficie); x < 0 la desactiva.
@export var secret_grove: Vector2 = Vector2(-1, -1)
## Fragmentos opcionales con IDs estables; no ocupan las manos ni abren la salida.
@export var fragment_ids: Array[String] = []
@export var fragment_positions: Array[Vector2] = []
@export var firefly_nest: Vector2 = Vector2(-1, -1)
## Inicio de cada tramo y nombre para orientar el recorrido largo.
@export var region_starts: Array[Vector2] = []
@export var region_names: Array[String] = []
## x, y, límite izquierdo y límite derecho de cada patrulla.
@export var enemy_spawns: Array[Vector4] = []
## Array tipado: PackedStringArray se exportaba vacío en el recurso binario del APK.
@export var enemy_kinds: Array[String] = []
## x, y e índice del catálogo de arrojadizos.
@export var object_spawns: Array[Vector3] = []
@export var crystal_positions: Array[Vector2] = []
## Exactamente tres llaves por intento. El arte se elige por entorno, no por color.
@export var key_definition: LevelKeyDefinition
@export var key_positions: Array[Vector2] = []
