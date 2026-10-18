class_name WorldCatalog
extends RefCounted
## Avance visual de ocho mundos. Solo se publican rutas que existen y son jugables.

const FOREST_SCENE := "res://game/boot/main.tscn"
const WORLDS: Array[Dictionary] = [
	{"id": "world_01", "name": "Bosque Esmeralda", "cell": Vector2i(0, 0), "scene": FOREST_SCENE, "detail": "Árboles, puentes y lianas", "beat": "¡De rama en rama!", "pose": &"run"},
	{"id": "world_02", "name": "Costa de Coral", "cell": Vector2i(1, 0), "scene": "", "detail": "Playas y arrecifes", "beat": "¡Un salto sobre las olas!", "pose": &"jump_up"},
	{"id": "world_03", "name": "Ruinas del Sol", "cell": Vector2i(2, 0), "scene": "", "detail": "Dunas y templos de arenisca", "beat": "¿Qué habrá en esa vasija?", "pose": &"carry_run"},
	{"id": "world_04", "name": "Cumbres de Hielo", "cell": Vector2i(3, 0), "scene": "", "detail": "Montañas de nieve y hielo", "beat": "¡Uy, que resbala!", "pose": &"fall"},
	{"id": "world_05", "name": "Cuevas de Cristal", "cell": Vector2i(3, 1), "scene": "", "detail": "Grutas y geodas de amatista", "beat": "¡Puntería de explorador!", "pose": &"throw"},
	{"id": "world_06", "name": "Pantano de Raíces", "cell": Vector2i(2, 1), "scene": "", "detail": "Manglares y raíces retorcidas", "beat": "¡Agárrate, Diego!", "pose": &"vine_hang"},
	{"id": "world_07", "name": "Islas del Cielo", "cell": Vector2i(1, 1), "scene": "", "detail": "Rocas flotantes entre nubes", "beat": "¡Hasta las nubes!", "pose": &"double_jump"},
	{"id": "world_08", "name": "Volcán de Obsidiana", "cell": Vector2i(0, 1), "scene": "", "detail": "Basalto y ríos de lava", "beat": "¡La aventura acaba de empezar!", "pose": &"victory"},
]


static func scene_for(world_id: String) -> String:
	# El bloqueo se valida aquí, además de presentarse en la interfaz.
	for world in WORLDS:
		if world.id == world_id:
			return world.scene
	return ""
