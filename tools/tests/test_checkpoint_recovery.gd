extends SceneTree
## Recuperación espacial con mecanismos reales: antes, después y a ambos lados del farol.

var checks: int = 0
var failures: int = 0
var stage: ForestStage
var hero: DiegoPlayer


func _initialize() -> void:
	_run.call_deferred()


func step(frames: int = 2) -> void:
	for frame in frames:
		await physics_frame
		await process_frame


func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
	print("%s %s" % ["OK" if ok else "FALLO", message])


func activate(target: ForestThrowTarget) -> void:
	target.break_apart()
	target.activated.emit(target.definition.mechanism_id)


func freeze() -> void:
	for enemy in stage.enemies:
		if is_instance_valid(enemy):
			enemy.set_physics_process(false)
	for object in stage.pine_stations + stage.object_stations:
		object.set_physics_process(false)
	for platform in stage.moving_platforms:
		platform.set_physics_process(false)
	stage.secret_grove.lift.set_physics_process(false)
	for crossing in stage.vine_crossings:
		for vine in crossing.vines:
			vine.set_physics_process(false)


func _run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	stage = ForestStage.new()
	stage.DEFINITION = stage.DEFINITION.duplicate()
	# Faroles de prueba sobre el bosque real; uno queda entre diana y barrera.
	stage.DEFINITION.checkpoints = [Vector2(3390, 600), Vector2(11000, 600), Vector2(17000, 600), Vector2(33000, 600)]
	world.add_child(stage)
	hero = preload("res://game/features/player/diego.tscn").instantiate()
	world.add_child(hero)
	stage.start(hero)
	hero.set_physics_process(false)
	stage.set_physics_process(false)
	freeze()
	await step()
	activate(stage.throw_targets[0])
	activate(stage.throw_targets[stage.bridges.size()])
	stage.enemies[0].defeat(false)
	stage.respawn_player()
	freeze()
	await step()
	check(stage.bridges[0].state == RootBridge.State.CLOSED and stage.throw_targets[0].active, "sin farol se reinicia también el primer puente")
	check(stage.root_gates[0].activated.is_empty() and stage.activated_mechanisms.is_empty(), "sin farol no quedan marcas ni activaciones sueltas")
	check(stage.enemies[0].active and stage.defeated_enemies == 0, "sin farol vuelve la patrulla inicial sin inflar derrotas")

	activate(stage.throw_targets[0])
	activate(stage.throw_targets[1])
	stage.enemies[0].defeat(false)
	stage.enemies[2].defeat(true) # Origen en x=4710, después del primer farol.
	stage._on_checkpoint(hero, 0)
	await step(42)
	stage.respawn_player()
	freeze()
	await step()
	check(stage.bridges[0].state == RootBridge.State.OPEN and not stage.bridges[0]._shape.disabled, "el puente cruzado conserva suelo transitable detrás del farol")
	check(not stage.throw_targets[0].active and stage.throw_targets[0].collision_layer == 0, "la diana anterior conserva la rotura junto a su puente")
	check(stage.bridges[1].state == RootBridge.State.CLOSED and stage.throw_targets[1].active, "el puente abierto por delante se cierra y su diana se reconstruye")
	check(not is_instance_valid(stage.enemies[0]) and stage.enemies[2].active, "avanzar el farol conserva solo las derrotas que quedan atrás")
	check(stage.defeated_enemies == 1, "una derrota futura previa a activar el farol sigue pendiente de repetirse")
	check(stage.activated_mechanisms == [stage.bridges[0].definition.mechanism_id], "el registro coincide con los mecanismos conservados")

	# Un enemigo anterior puede haberse dejado vivo y eliminarse al volver atrás.
	stage.enemies[1].defeat(true)
	stage.respawn_player()
	freeze()
	check(not stage.enemies[1].active and stage.defeated_enemies == 2, "volver atrás no repone una derrota anterior al punto de reaparición")
	var stable_id: int = stage.enemies[2].get_instance_id()
	stage.respawn_player()
	freeze()
	check(stage.enemies[2].get_instance_id() == stable_id and stage.enemies.size() == 45, "reintentos consecutivos mantienen una sola instancia por patrulla")
	check(stage.bridges[0].state == RootBridge.State.OPEN, "repetir la muerte no borra un puente consolidado")

	# Conservar un portón resuelto, y rearmar como unidad el que cruza el farol.
	for target in stage.throw_targets:
		activate(target)
	await step(42)
	stage._on_checkpoint(hero, 1)
	var previous_object: ThrowableObject = stage.object_stations[0]
	var future_object: ThrowableObject = stage.object_stations[6]
	var first_station: int = stage.bridges.size() + 2
	var straddling_pine: ThrowableObject = stage.pine_stations[first_station]
	straddling_pine.position += Vector2(160, -30)
	straddling_pine.state = ThrowableObject.State.THROWN
	previous_object.position += Vector2(45, -10)
	future_object.position += Vector2(90, -20)
	var previous_object_at: Vector2 = previous_object.position
	var old_platform: ForestMovingPlatform = stage.moving_platforms[0]
	var new_platform: ForestMovingPlatform = stage.moving_platforms[2]
	old_platform.elapsed = 2.5
	new_platform.elapsed = 2.5
	var old_enemy: ForestEnemy = stage.enemies[9]
	var new_enemy: ForestEnemy = stage.enemies[13]
	old_enemy.position += Vector2(100, 0)
	new_enemy.position += Vector2(100, 0)
	var old_enemy_at: Vector2 = old_enemy.position
	stage.respawn_player()
	freeze()
	await step()
	check(stage.bridges[0].state == RootBridge.State.OPEN and stage.bridges[1].state == RootBridge.State.OPEN, "un farol posterior consolida los dos primeros puentes")
	check(stage.root_gates[0].is_open and stage.root_gates[0]._shape.disabled, "el portón anterior conserva su apertura y sus dos marcas")
	check(not stage.root_gates[1].is_open and stage.root_gates[1].activated.is_empty(), "el portón posterior vuelve a exigir ambas dianas")
	var straddling: RootBridgeDefinition = stage.root_gates[1].definition.stations[0]
	check(straddling.target_position.x < stage.respawn_position.x and stage.throw_targets[first_station].active, "una diana anterior se rearma si acciona un portón posterior")
	check(straddling_pine.state == ThrowableObject.State.FREE and straddling_pine.position == straddling_pine._spawn_position, "la herramienta del mismo puzzle vuelve a su puesto aunque esté antes del farol")
	check(previous_object.position == previous_object_at and future_object.position == future_object._spawn_position, "los objetos se recuperan por su puesto de origen y conservan el tramo anterior")
	check(old_platform.elapsed == 2.5 and new_platform.elapsed == 0.0, "los troncos posteriores reinician su ciclo y los anteriores continúan")
	check(old_enemy.position == old_enemy_at and new_enemy.position == new_enemy._home, "solo las patrullas posteriores regresan a su puesto")
	stage._on_checkpoint(hero, 0)
	check(stage.active_checkpoint_index == 1, "volver a un farol anterior no retrocede el punto de reaparición")
	for station in stage.root_gates[1].definition.stations:
		for target in stage.throw_targets:
			if target.definition.mechanism_id == station.mechanism_id:
				activate(target)
	stage.respawn_player()
	freeze()
	check(stage.root_gates[0].is_open and not stage.root_gates[1].is_open, "resolver y morir de nuevo repite solo el puzzle posterior")

	# Consolidar el siguiente puzzle, el secreto y después el barranco completo.
	activate(stage.throw_targets[first_station])
	activate(stage.throw_targets[first_station + 1])
	stage._on_checkpoint(hero, 2)
	stage.secret_grove._on_reward_body_entered(hero)
	stage.secret_grove.lift.elapsed = 2.0
	stage.respawn_player()
	freeze()
	check(stage.root_gates[1].is_open, "al superar el portón queda conservado en el nuevo farol")
	check(stage.secret_grove.reward_taken and stage.secret_grove.lift.elapsed == 2.0, "el secreto superado conserva su recompensa y el ciclo del ascensor")
	var vine: ForestSwingingVine = stage.vine_crossings[0].vines[0]
	vine.grip_velocity = Vector2(120, 30)
	stage.respawn_player()
	check(vine.grip_velocity == Vector2.ZERO, "un barranco posterior reinicia sus lianas")
	stage._on_checkpoint(hero, 3)
	vine.grip_velocity = Vector2(120, 30)
	stage.respawn_player()
	check(vine.grip_velocity == Vector2(120, 30), "un barranco superado mantiene su ciclo al morir más adelante")
	world.queue_free()
	await step()
	print("RECUPERACIÓN POR FAROL: %d comprobaciones, %d fallos" % [checks, failures])
	quit(0 if failures == 0 else 1)
