class_name ForestAdventureCatalog
extends RefCounted
## Rutas explícitas y desbloqueo por aventura, compatible con progress.json v1.

const LEVELS: Array[Dictionary] = [
	{"id": "world_01_level_01", "name": "1–1 · El despertar del bosque", "scene": "res://game/boot/main.tscn", "requires": "", "detail": "Puentes, troncos y las primeras lianas"},
	{"id": "world_01_level_02", "name": "1–2 · Las copas del bosque", "scene": "res://game/boot/forest_level_02.tscn", "requires": "world_01_level_01", "detail": "Setas elásticas y aventuras entre las copas"},
]


static func scene_for(id: String, progress: LevelProgress) -> String:
	for level in LEVELS:
		if level.id == id and (level.requires.is_empty() or progress.is_completed(level.requires)):
			return level.scene
	return ""


static func next_after(id: String, progress: LevelProgress) -> String:
	for index in range(LEVELS.size() - 1):
		if LEVELS[index].id == id:
			return scene_for(LEVELS[index + 1].id, progress)
	return ""
