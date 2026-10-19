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
		_check(exported.checkpoints == [Vector2(12390, 600), Vector2(24390, 600), Vector2(36390, 600)],
			"el APK contiene exactamente los tres puntos de guardado del bosque")
		_check(exported.enemy_spawns == preload("res://game/data/worlds/world_01/level_01.tres").enemy_spawns,
			"las posiciones y patrullas sobreviven a la exportación binaria")
		_check(exported.enemy_kinds == preload("res://game/data/worlds/world_01/level_01.tres").enemy_kinds and exported.enemy_kinds.size() == exported.enemy_spawns.size(),
			"los tipos de enemigos sobreviven a la exportación binaria")
		_check(exported.root_gates.size() == 10 and exported.root_gates[9].stations.size() == 2, "los pasos dobles y sus estaciones sobreviven al APK")
		_check(exported.vine_crossings.size() == 1 and exported.vine_crossings[0] == Vector2(24200, 0), "la liana sobrevive al recurso binario del APK")
		_check(exported.key_positions == preload("res://game/data/worlds/world_01/level_01.tres").key_positions, "las tres llaves repartidas sobreviven al APK")
		_check(exported.secret_grove == Vector2(11610, 600), "la gruta secreta sobrevive a la exportación binaria del APK")
		_check(exported.fragment_ids == ["clear", "grove", "vines"] and exported.fragment_positions.size() == 3,
			"los tres fragmentos y sus IDs sobreviven al recurso del APK")
		_check(exported.firefly_nest == Vector2(480, 565), "el nido del ayudante sobrevive a la exportación binaria")
	var second := ResourceLoader.load("res://.godot-logs/apk-level_02.res", "", ResourceLoader.CACHE_MODE_IGNORE) as ForestLevelDefinition
	_check(second != null, "Bosque 1-2 está presente en el APK")
	if second != null:
		var source: ForestLevelDefinition = preload("res://game/data/worlds/world_01/level_02.tres")
		_check(second.level_id == source.level_id and second.level_number == 2, "Identidad de la segunda aventura exportada")
		_check(second.spring_positions == source.spring_positions and second.spring_positions.size() == 4, "Cuatro setas elásticas exportadas")
		_check(second.checkpoints == source.checkpoints and second.checkpoints.size() == 3, "Tres faroles del segundo nivel exportados")
		_check(second.key_positions == source.key_positions and second.crystal_positions == source.crystal_positions, "Llaves y cristales intermedios exportados")
		_check(second.enemy_kinds.size() == 66 and second.enemy_kinds == source.enemy_kinds, "Enemigos del segundo nivel exportados")
		_check(second.enemy_kinds.count("noctilo") == 8 and second.enemy_spawns == source.enemy_spawns, "Ocho vuelos de murciélago con rutas fijas sobreviven al APK")
		_check(second.canopy_secret == Vector2(19660, 600), "Acceso del sendero secreto en las copas exportado")
	print("RESULTADO DATOS APK: %d comprobaciones, %d fallos" % [_checks, _failures])
	quit(0 if _failures == 0 else 1)

