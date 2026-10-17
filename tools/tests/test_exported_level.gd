extends SceneTree
## Lee los datos binarios extraídos del APK, no el .tres que usa el editor.

var _checks: int = 0
var _failures: int = 0


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
	print("%s %s" % ["OK" if condition else "FALLO", description])


func _initialize() -> void:
	var exported := ResourceLoader.load("res://.godot-logs/apk-level_01.res", "", ResourceLoader.CACHE_MODE_IGNORE) as ForestLevelDefinition
	_check(exported != null, "el recurso real del APK se puede cargar")
	if exported != null:
		_check(exported.enemy_spawns == preload("res://game/data/worlds/world_01/level_01.tres").enemy_spawns,
			"las posiciones y patrullas sobreviven a la exportación binaria")
		_check(exported.enemy_kinds == preload("res://game/data/worlds/world_01/level_01.tres").enemy_kinds and exported.enemy_kinds.size() == exported.enemy_spawns.size(),
			"los tipos de enemigos sobreviven a la exportación binaria")
		_check(exported.root_gates.size() == 10 and exported.root_gates[9].stations.size() == 2, "los pasos dobles y sus estaciones sobreviven al APK")
		_check(exported.vine_crossings.size() == 1 and exported.vine_crossings[0] == Vector2(24200, 0), "la liana sobrevive al recurso binario del APK")
		_check(exported.key_positions == preload("res://game/data/worlds/world_01/level_01.tres").key_positions, "las tres llaves repartidas sobreviven al APK")
		_check(exported.secret_grove == Vector2(11610, 600), "la gruta secreta sobrevive a la exportación binaria del APK")
	print("RESULTADO DATOS APK: %d comprobaciones, %d fallos" % [_checks, _failures])
	quit(0 if _failures == 0 else 1)
