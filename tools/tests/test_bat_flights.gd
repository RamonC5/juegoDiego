extends "res://tools/tests/test_forest_route.gd"
## Vuelo independiente, contacto/pisotón reales y recuperación espacial del nivel 2.

var _live_flights: bool = false


func step(frames: int) -> void:
	for frame in frames:
		if _live_flights:
			hero.invulnerability = 0.0
		await super.step(1)


func _run() -> void:
	main = load("res://game/boot/forest_level_02.tscn").instantiate()
	main.collection_progress = CollectionProgress.new("user://bat-test-%d.json" % Time.get_ticks_usec())
	root.add_child(main)
	stage = main.stage
	hero = main.player
	await step(5)
	var bats: Array[ForestEnemy] = []
	for enemy in stage.enemies:
		enemy.set_physics_process(false)
		if enemy.kind == "noctilo":
			bats.append(enemy)
		else:
			enemy._contact.monitoring = false
	check(bats.size() == 8 and stage.enemies.size() == 66, "Ocho murciélagos junto a las 58 patrullas anteriores")
	check(stage.checkpoint_positions().size() == 3, "Conservar exactamente tres faroles")
	check(preload("res://game/data/worlds/world_01/level_01.tres").enemy_kinds.count("noctilo") == 0, "El nivel 1 conserva su reparto")
	var bat: ForestEnemy = bats[0]
	check(bat.has_visible_art() and bat._visual.profile.flying, "Raster existente y perfil de alas en el nivel real")
	# Mismo reloj y trayectoria con el jugador a cada lado, encima y debajo.
	hero.set_physics_process(false)
	var maximum_speed: float = 0.0
	for tick in 900:
		var dt: float = 1.0 / 60.0
		var sample: float = float(tick + 1) * dt
		var previous: Vector2 = bat.position
		hero.position = bat._home + Vector2(350 if tick % 2 == 0 else -350, -180 if tick % 3 == 0 else 200)
		bat._physics_process(dt)
		maximum_speed = maxf(maximum_speed, previous.distance_to(bat.position) / dt)
		if tick % 90 == 0:
			check(bat.position.distance_to(bat.flight_position(sample)) < 0.01 and bat.behaviour == ForestEnemy.Behaviour.PATROL and not bat.can_see_player(), "El vuelo conserva ruta y altura aunque Diego cambie de posición")
	check(maximum_speed < 135.0, "Giros suaves y velocidad legible sin saltos de posición")
	check(bat.position.y < bat._home.y + 13.0, "No cae por gravedad ni sigue a Diego hacia el suelo")
	bat.set_physics_process(true)
	var frozen: Vector2 = bat.position
	var wing_phase: float = bat._visual.phase
	paused = true
	await step(20)
	check(bat.position == frozen and bat._visual.phase == wing_phase, "La pausa congela vuelo y aleteo")
	paused = false
	bat.set_physics_process(false)
	hero.set_physics_process(true)
	for flyer in bats:
		var bounded: bool = true
		for tick in 25:
			var point: Vector2 = flyer.flight_position(float(tick))
			bounded = bounded and point.x >= flyer.patrol.x and point.x <= flyer.patrol.y and absf(point.y - flyer._home.y) <= ForestEnemy.FLIGHT_BOB
		check(bounded, "Vuelo %d: ruta acotada y huecos estables entre alturas" % flyer.spawn_index)
		flyer.reset_awareness()
		flyer.set_physics_process(true)
	stage.vine_crossings[0].reset_vines()
	_live_flights = true
	var crossed: bool = await cross_vine_ravine()
	_live_flights = false
	check(crossed and hero.health == 3, "Ensayo: cinco lianas con vuelos activos, entradas reales y sin protección ni daño")
	for flyer in bats:
		flyer.set_physics_process(false)
	# Daño físico lateral, incluyendo soltar una liana real.
	var vine: ForestSwingingVine = stage.vine_crossings[0].vines[0]
	hero.respawn(bat.position + Vector2(0, 40))
	hero.invulnerability = 0.0
	hero.attached_vine = vine
	bat._contact.monitoring = true
	await step(1)
	# Congelar solo el desplazamiento de Diego mientras los sensores sincronizan.
	hero.set_physics_process(false)
	hero.position = bat.position + Vector2(0, 40)
	await step(3)
	bat._physics_process(0.0)
	check(hero.health == 2 and hero.attached_vine == null, "Contacto lateral quita un corazón y suelta el agarre")
	bat._physics_process(0.0)
	check(hero.health == 2, "La invulnerabilidad evita daño repetido por el mismo contacto")
	hero.set_physics_process(true)
	# Pisotón con caída, sensor de pies y rebote auténticos.
	hero.respawn(bat.position + Vector2(0, -125))
	hero.invulnerability = 0.0
	hero.velocity.y = 260.0
	for tick in 60:
		await step(1)
		if not bat.active:
			break
	check(not bat.active and hero.velocity.y < 0.0 and hero.health == 3, "Caer encima derrota al murciélago y produce rebote sin daño")
	# El farol consolida derrotas anteriores; las posteriores se reponen una vez.
	stage._on_checkpoint(hero, 0)
	var after: ForestEnemy = bats[2]
	var before_index: int = bat.spawn_index
	var after_index: int = after.spawn_index
	after.defeat(false)
	stage.respawn_player()
	await step(2)
	check(not is_instance_valid(stage.enemies[before_index]) or not stage.enemies[before_index].active, "La derrota anterior al farol permanece")
	var restored: ForestEnemy = stage.enemies[after_index]
	check(restored.active and restored.kind == "noctilo" and restored.flight_seconds == 0.0, "La derrota posterior reaparece con su ciclo inicial")
	check(stage.defeated_enemies == 1 and stage.enemies.size() == 66, "La reaparición no duplica enemigos ni derrotas")
	# Suelo seguro bajo el primer vuelo: caminar sin saltar no causa daño.
	hero.respawn(Vector2(11050, 600))
	hero.invulnerability = 0.0
	for enemy in stage.enemies:
		if is_instance_valid(enemy) and enemy.active and enemy.kind == "noctilo":
			enemy.set_physics_process(true)
	hero.controls.set_virtual_axis(1.0)
	await step(65)
	hero.controls.clear_virtual()
	check(hero.health == 3 and hero.is_on_floor(), "La primera observación se hace sobre orilla firme sin daño")
	_finish()
