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
		_check(exported.enemy_spawns == ForestStage.DEFINITION.enemy_spawns,
			"las nueve posiciones y patrullas sobreviven a la exportación binaria")
		_check(exported.enemy_kinds == ForestStage.DEFINITION.enemy_kinds and exported.enemy_kinds.size() == 9,
			"los nueve tipos de enemigos sobreviven a la exportación binaria")
	print("RESULTADO DATOS APK: %d comprobaciones, %d fallos" % [_checks, _failures])
	quit(0 if _failures == 0 else 1)
