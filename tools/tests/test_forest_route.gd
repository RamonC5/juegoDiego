extends SceneTree
## Ruta geométrica continua con controles y lanzamientos reales.
## Se excluye la colisión con enemigos para aislar geometría; combate se prueba aparte.

var main: Node2D
var hero: DiegoPlayer
var stage: ForestStage
var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func step(count: int) -> void:
	for frame in count:
		await physics_frame
		await process_frame


func check(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
	print("%s %s · posición %s" % ["OK" if ok else "FALLO", message, hero.position])
	return ok


func walk_to(x: float, max_frames: int = 2200) -> bool:
	hero.controls.automatic_run = true
	hero.controls.full_jump = true
	for frame in max_frames:
		if stage.completed:
			return true
		if hero.dead:
			return false
		var diff: float = x - hero.position.x
		if absf(diff) < 7.0:
			hero.controls.clear_virtual()
			await step(10)
			return true
		var direction: float = signf(diff)
		hero.controls.set_virtual_axis(direction)
		if hero.is_on_floor():
			hero.controls.set_virtual_action(&"jump", false)
			for section in stage.DEFINITION.ground_sections:
				var distance: float = (section.end.x - hero.position.x) if direction > 0 else (hero.position.x - section.position.x)
				if distance > 0 and distance < 58 and absf(hero.position.y - section.position.y) < 3:
					hero.controls.set_virtual_action(&"jump", true)
		await step(1)
	hero.controls.clear_virtual()
	return false


func jump_to(x: float, floor_y: float) -> bool:
	hero.controls.set_virtual_action(&"jump", false)
	await step(2)
	hero.controls.set_virtual_action(&"jump", true)
	for frame in 100:
		var diff: float = x - hero.position.x
		hero.controls.set_virtual_axis(signf(diff) if absf(diff) > 5 else 0.0)
		await step(1)
		if frame > 12 and hero.is_on_floor():
			hero.controls.clear_virtual()
			await step(3)
			return absf(hero.position.y - floor_y) < 4
	hero.controls.clear_virtual()
	return false


func ground_to(x: float) -> bool:
	if hero.position.y < 590 and hero.is_on_floor():
		for rect in stage.DEFINITION.raised_platforms:
			if absf(hero.position.y - rect.position.y) < 4 and hero.position.x >= rect.position.x - 30 and hero.position.x <= rect.end.x + 30:
				if not await walk_to(rect.end.x + 80):
					return false
				await step(65)
				break
	if not await walk_to(x):
		return false
	await step(50)
	return hero.is_on_floor() and absf(hero.position.y - 600) < 4


func reach_station(station: RootBridgeDefinition) -> bool:
	var floor_y: float = station.pine_position.y + 26
	if floor_y > 590:
		return await ground_to(station.pine_position.x)
	var crest := Rect2()
	for rect in stage.DEFINITION.raised_platforms:
		if absf(rect.position.y - floor_y) < 2 and station.pine_position.x > rect.position.x and station.pine_position.x < rect.end.x:
			crest = rect
			break
	if not crest.has_area():
		return false
	var chain: Array[Rect2] = [crest]
	while chain[0].position.y < 485:
		var previous := Rect2()
		for rect in stage.DEFINITION.raised_platforms:
			if absf(rect.position.y - chain[0].position.y - 85) < 2 and absf(rect.end.x - chain[0].position.x + 20) < 2:
				previous = rect
				break
		if not previous.has_area():
			break
		chain.push_front(previous)
	if chain[0].position.y >= 485:
		var reached_ground: bool = await ground_to(chain[0].position.x + 90)
		# El salto más alto sobre el hueco anterior puede aterrizar directamente en
		# la primera terraza. Ese acceso físico ya ha completado el primer ascenso.
		var on_first_step: bool = hero.is_on_floor() and absf(hero.position.y - chain[0].position.y) < 4 and hero.position.x >= chain[0].position.x and hero.position.x <= chain[0].end.x
		if not reached_ground and not on_first_step:
			return false
		if not on_first_step and not await jump_to(chain[0].position.x + 90, chain[0].position.y):
			return false
		for index in range(1, chain.size()):
			if not await walk_to(chain[index - 1].end.x - 25):
				return false
			if not await jump_to(chain[index].position.x + 85, chain[index].position.y):
				return false
	else:
		# Las copas altas solo tienen acceso por el tronco que llega a su orilla.
		var lift: ForestMovingPlatform
		for platform in stage.moving_platforms:
			if absf(platform.definition.end_position.x - crest.position.x + 170) < 2 and absf(platform.definition.end_position.y - crest.position.y - 35) < 2:
				lift = platform
				break
		if lift == null or not await ground_to(lift.definition.start_position.x):
			return false
		var boarded: bool = false
		for frame in 650:
			if lift.carries(hero):
				boarded = true
				break
			if hero.is_on_floor() and lift.position.y > 510:
				hero.controls.set_virtual_action(&"jump", false)
				await step(1)
				hero.controls.set_virtual_action(&"jump", true)
			await step(1)
		hero.controls.clear_virtual()
		if not boarded:
			return false
		for frame in 650:
			if lift.position.y <= lift.definition.end_position.y + 4:
				break
			await step(1)
		if not await walk_to(lift.position.x + 90):
			return false
		if not await jump_to(crest.position.x + 85, crest.position.y):
			return false
	return await walk_to(station.pine_position.x)


func throw_station(station: RootBridgeDefinition) -> bool:
	if not await reach_station(station):
		return false
	hero.controls.set_virtual_axis(1)
	await step(2)
	hero.controls.set_virtual_axis(0)
	await step(5)
	for action in 2:
		hero.controls.set_virtual_action(&"grab_throw", true)
		await step(1)
		hero.controls.set_virtual_action(&"grab_throw", false)
		await step(25)
	await step(60)
	return stage.activated_mechanisms.has(station.mechanism_id)


func cross_vine_ravine() -> bool:
	# Prueba el gesto real de subir, soltar y correr; los discos rebotan solos.
	var crossing: ForestVineCrossing = stage.vine_crossings[0]
	hero.respawn(crossing.global_position + Vector2(ForestVineCrossing.VINE_X, 600))
	hero.invulnerability = 100000.0
	hero.controls.set_virtual_action(&"jump", true)
	var reached_top: bool = false
	for frame in 150:
		await step(1)
		if hero.global_position.y < 318:
			reached_top = true
			break
	if not reached_top:
		hero.controls.clear_virtual()
		return false
	# La salida de la liana añade impulso para el primer disco.
	hero.controls.set_virtual_action(&"jump", false)
	hero.controls.set_virtual_axis(1.0)
	var shattered: int = 0
	for frame in 460:
		await step(1)
		for target in crossing.targets:
			if not target.intact:
				shattered = maxi(shattered, crossing.targets.find(target) + 1)
		if hero.global_position.x > crossing.global_position.x + 3275:
			hero.controls.clear_virtual()
			return shattered >= 3 and hero.is_on_floor()
		if hero.dead:
			break
	hero.controls.clear_virtual()
	return false


func _run() -> void:
	main = load("res://game/boot/main.tscn").instantiate()
	root.add_child(main)
	stage = main.stage
	hero = main.player
	main.progress = LevelProgress.new("user://expanded-route-progress.json")
	await step(8)
	hero.invulnerability = 100000.0
	hero.collision_mask = 1
	hero.foot_sensor.collision_mask = 0
	for enemy in stage.enemies:
		enemy.set_physics_process(false)
		enemy.collision_layer = 0
		enemy._stomp.collision_layer = 0
		enemy._contact.monitoring = false
	for index in 2:
		if not check(await throw_station(stage.DEFINITION.bridges[index]), "prólogo: puente %d mediante entrada real" % index):
			_finish()
			return
	for index in stage.root_gates.size():
		var gate: ForestRootGate = stage.root_gates[index]
		if not check(await throw_station(gate.definition.stations[0]), "tramo %d: ascenso y primera diana" % index):
			_finish()
			return
		if index == 5:
			if not check(await cross_vine_ravine(), "barranco: subir liana y rebotar por las dianas para alcanzar tierra firme"):
				_finish()
				return
		for bridge in stage.bridges:
			if bridge.state == RootBridge.State.CLOSED and bridge.definition.pine_position.x > gate.definition.stations[0].pine_position.x and bridge.definition.pine_position.x < gate.position.x:
				if not check(await throw_station(bridge.definition), "tramo %d: puente intermedio" % index):
					_finish()
					return
		if not check(await throw_station(gate.definition.stations[1]), "tramo %d: segunda diana" % index):
			_finish()
			return
		if not check(gate.is_open and await ground_to(gate.position.x + 105), "tramo %d: cruzar las raíces abiertas" % index):
			_finish()
			return
		if index in [3, 6, 9]:
			check(stage.collected_keys.size() == index / 3, "llave de la ruta %d recogida físicamente" % (index / 6))
	check(await ground_to(stage.DEFINITION.goal.x - 20), "recorrido continuo hasta la puerta")
	check(stage.completed and stage.collected_keys.size() == 3 and not hero.dead, "salida y resultado de las tres rutas")
	print("RUTA GEOMÉTRICA: %.1f s simulados con protección; no es una primera partida del público objetivo" % stage.seconds)
	_finish()


func _finish() -> void:
	main.queue_free()
	paused = false
	await step(3)
	DirAccess.remove_absolute("user://expanded-route-progress.json")
	print("RESULTADO RUTA AMPLIADA: %d comprobaciones, %d fallos" % [checks, failures])
	await preload("res://tools/tests/audio_cleanup.gd").flush(self)
	quit(0 if failures == 0 else 1)

