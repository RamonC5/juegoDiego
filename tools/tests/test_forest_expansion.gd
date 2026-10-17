extends SceneTree
## Bosque real: percepción, límites, dos marcas, recuperación y datos completos.

var main: Node2D
var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func step(count: int) -> void:
	for frame in count:
		await physics_frame
		await process_frame


func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
	print("%s %s" % ["OK" if ok else "FALLO", message])


func _run() -> void:
	main = load("res://game/boot/main.tscn").instantiate()
	root.add_child(main)
	await step(8)
	var stage: ForestStage = main.stage
	var hero: DiegoPlayer = main.player
	check(stage.DEFINITION.width == 44600.0 and stage.DEFINITION.region_names.size() == 10, "10 tramos en el bosque condensado")
	check(stage.enemies.size() == 45 and stage.DEFINITION.enemy_kinds.size() == 45 and stage.DEFINITION.enemy_kinds.has("terron") and stage.DEFINITION.enemy_kinds.has("moflete"), "45 enemigos de los dos tipos")
	check(stage.root_gates.size() == 10 and stage.bridges.size() == 4 and stage.moving_platforms.size() == 5 and stage.vine_crossings.size() == 1, "retos combinados de marcas, puentes y troncos")
	check(stage.level_keys.size() == 3 and stage.level_keys[0].position.x > 19800 and stage.level_keys[1].position.x > 31800 and stage.level_keys[2].position.x > 43800, "tres llaves repartidas por las tres rutas")
	var platform_count: int = 0
	for enemy in stage.enemies:
		enemy.set_physics_process(false)
		if enemy.platform_guard:
			platform_count += 1
	check(platform_count >= 17, "los guardianes de las repisas siguen reconociendo sus límites")
	# Percepción y persecución de ambos tipos, sin interferencia de otras patrullas.
	hero.set_physics_process(false)
	for index in [0, 1]:
		var enemy: ForestEnemy = stage.enemies[index]
		enemy.reset_awareness()
		hero.respawn(enemy.position + Vector2(-350, 0))
		hero.invulnerability = 99
		enemy.set_physics_process(true)
		var start_x: float = enemy.position.x
		await step(3)
		check(enemy.behaviour == ForestEnemy.Behaviour.NOTICE and enemy._notice_seconds > 0.0, "%s anticipa el ataque al detectar a Diego" % enemy.kind)
		check(absf(enemy.position.x - start_x) < 2, "%s concede tiempo para reaccionar" % enemy.kind)
		await step(80)
		check(enemy.behaviour == ForestEnemy.Behaviour.CHASE and enemy.position.x < start_x - 60 and enemy.position.x < enemy.patrol.x, "%s abandona la patrulla para atacar" % enemy.kind)
		var before: Vector2 = enemy.position
		main._toggle_pause()
		await step(30)
		check(enemy.position == before, "la pausa congela también la persecución")
		main._resume()
		hero.dead = true
		await step(4)
		check(enemy.behaviour == ForestEnemy.Behaviour.RETURN or enemy.behaviour == ForestEnemy.Behaviour.PATROL, "%s deja de atacar a Diego derrotado" % enemy.kind)
		hero.dead = false
		enemy.set_physics_process(false)
		enemy.reset_awareness()
	# Pared opaca: no detectar ni seguir la posición actual a través del terreno.
	var first: ForestEnemy = stage.enemies[0]
	var wall := StaticBody2D.new()
	wall.position = first.position + Vector2(-140, -120)
	wall.collision_layer = 1
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(40, 240)
	shape.shape = rectangle
	wall.add_child(shape)
	stage.add_child(wall)
	hero.respawn(first.position + Vector2(-300, 0))
	first.set_physics_process(true)
	await step(12)
	check(not first.can_see_player() and first.behaviour == ForestEnemy.Behaviour.PATROL, "la visión no atraviesa paredes")
	wall.queue_free()
	await step(4)
	check(first.behaviour == ForestEnemy.Behaviour.NOTICE, "retirar la pared permite detectar de nuevo")
	first.set_physics_process(false)
	first.reset_awareness()
	# Las patrullas tranquilas conservan los apoyos originales del nivel real.
	for index in [3, 4]:
		var guard: ForestEnemy = stage.enemies[index]
		guard.set_physics_process(true)
		hero.dead = true
		hero.position = guard.position
		await step(180)
		check(guard.position.x >= guard.movement_bounds.x - 0.1 and guard.position.x <= guard.movement_bounds.y + 0.1 and absf(guard.position.y - guard._home.y) < 2, "%s patrulla sin caerse al estar tranquilo" % guard.kind)
		hero.dead = false
		guard.set_physics_process(false)
		guard.reset_awareness()
		check(guard.position == guard._home and not guard._has_pursued, "el farol restablece el origen y la patrulla de %s" % guard.kind)
	# Suelo: frenar ante el vacío, incluso con el objetivo visible al otro lado.
	var edge: ForestEnemy = stage.enemies[0]
	edge.reset_awareness()
	hero.respawn(Vector2(1800, 600))
	edge.set_physics_process(true)
	await step(300)
	check(edge.position.x <= edge.movement_bounds.y + 0.1 and absf(edge.position.y - 600.0) < 2, "el perseguidor del suelo frena antes del hueco")
	edge.set_physics_process(false)
	# El paso cerrado bloquea también una carrera con salto; no se elude por arriba.
	hero.set_physics_process(true)
	hero.respawn(stage.root_gates[0].position - Vector2(150, 0))
	hero.invulnerability = 99
	await step(3)
	hero.controls.automatic_run = true
	hero.controls.full_jump = true
	hero.controls.set_virtual_axis(1)
	hero.controls.set_virtual_action(&"jump", true)
	await step(100)
	hero.controls.clear_virtual()
	check(hero.position.x < stage.root_gates[0].position.x - 20, "las raíces cerradas bloquean una carrera y salto completo")
	hero.set_physics_process(false)
	# Reglas de los diez pasos: una sola marca no abre; ambas sí y no se duplican.
	for index in stage.root_gates.size():
		var gate: ForestRootGate = stage.root_gates[index]
		var stations: Array[RootBridgeDefinition] = gate.definition.stations
		check(stations.size() == 2 and stations[0].pine_position.x < gate.position.x and stations[1].pine_position.x < gate.position.x, "paso %d tiene dos estaciones en la orilla accesible" % index)
		stage._on_mechanism_activated(stations[0].mechanism_id)
		await step(1)
		check(not gate.is_open and not gate._shape.disabled, "paso %d exige la segunda marca" % index)
		stage._on_mechanism_activated(stations[0].mechanism_id)
		check(gate.activated.size() == 1, "paso %d no duplica la primera marca" % index)
		stage._on_mechanism_activated(stations[1].mechanism_id)
		await step(1)
		check(gate.is_open and gate._shape.disabled, "paso %d permite cruzar y regresar tras ambas marcas" % index)
	# Se conserva progreso en el intento; el farol cura una vez al activarse.
	hero.set_physics_process(true)
	hero.respawn(stage.checkpoint_positions()[5])
	hero.health = 1
	stage._on_checkpoint(hero, 5)
	check(hero.health == 3, "un farol nuevo recupera la energía sin desplazar ni soltar objetos")
	stage.level_keys[0]._on_body_entered(hero)
	stage.respawn_player()
	await step(4)
	await step(3)
	check(stage.collected_keys == [0] and stage.root_gates.slice(0, 3).all(func(g: ForestRootGate): return g.is_open and g._shape.disabled), "el reintento conserva la llave y los tres portones anteriores al farol")
	check(stage.root_gates.slice(3).all(func(g: ForestRootGate): return not g.is_open and g.activated.is_empty() and not g._shape.disabled), "los siete portones posteriores vuelven a exigir sus dos marcas")
	check(stage.activated_mechanisms.size() == 6 and stage.bridges[0].state == RootBridge.State.CLOSED, "las marcas anteriores se conservan sin abrir puentes que no se resolvieron")
	check(stage.enemies.filter(func(e: ForestEnemy): return is_instance_valid(e) and e.active and e.spawn_index >= 17).all(func(e: ForestEnemy): return e.behaviour == ForestEnemy.Behaviour.PATROL), "reaparecer borra el estado de alerta de las patrullas posteriores")
	stage._on_goal(hero)
	check(not stage.completed, "una llave mantiene bloqueada la salida ampliada")
	var active_leaves: int = 0
	for leaf in stage.collectibles:
		if leaf.visible:
			active_leaves += 1
	check(active_leaves < 120 and stage.total_leaves > 220, "solo se animan y detectan las hojas de la zona cercana")
	for leaf in stage.collectibles:
		if leaf.visible and not leaf.taken:
			leaf._on_body_entered(hero)
			check(leaf.taken and not leaf.is_processing(), "una hoja recogida deja de consumir animación")
			break
	main.queue_free()
	paused = false
	await step(3)
	print("RESULTADO AMPLIACIÓN: %d comprobaciones, %d fallos" % [checks, failures])
	await preload("res://tools/tests/audio_cleanup.gd").flush(self)
	quit(0 if failures == 0 else 1)

