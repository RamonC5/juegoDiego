extends "res://tools/tests/test_forest_route.gd"
## Contratos, ciclo completo y lanzamientos reales desde la mano de Diego.

var arena: ForestBossStage
var boss: NudorBoss
var wins: int = 0


func pulse(action: StringName, after: int = 30) -> void:
	hero.controls.set_virtual_action(action, true)
	await step(1)
	hero.controls.set_virtual_action(action, false)
	await step(after)


func wait_state(target: NudorBoss.State, maximum: int = 900) -> bool:
	for frame in maximum:
		if boss.state == target:
			return true
		await step(1)
	return false


func _run() -> void:
	var storage: String = "user://nudor-%d-%d" % [OS.get_process_id(), Time.get_ticks_usec()]
	var progress := LevelProgress.new(storage + ".json")
	check(ForestAdventureCatalog.scene_for("world_01_boss", progress).is_empty(), "Nudor bloqueado en un perfil nuevo")
	progress.record_completion("world_01_level_03", {})
	check(ForestAdventureCatalog.scene_for("world_01_boss", progress).is_empty(), "Un registro aislado de 1-3 no omite las otras aventuras")
	progress.record_completion("world_01_level_01", {})
	progress.record_completion("world_01_level_02", {})
	progress = LevelProgress.new(storage + ".json")
	check(not ForestAdventureCatalog.scene_for("world_01_boss", progress).is_empty(), "Tres aventuras en guardado v1 desbloquean el encuentro")
	check(ForestAdventureCatalog.next_after("world_01_level_02", progress).ends_with("forest_level_03.tscn"), "Continuar desde 1-2 abre 1-3")
	check(ForestAdventureCatalog.next_after("world_01_level_03", progress).ends_with("forest_boss.tscn"), "Continuar desde 1-3 abre Nudor")
	var menu := ForestAdventureMenu.new()
	menu.progress = progress
	root.add_child(menu)
	for view in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(1024, 768)]:
		root.size = view
		root.content_scale_size = view
		await step(4)
		check(menu.level_buttons.size() == 4 and menu.level_buttons[3].has_focus(), "Selector con cuatro destinos y foco en Nudor %s" % view)
		check(menu._panel.get_global_rect().end.y <= view.y and menu._panel.position.y >= 0, "Selector y salida dentro de pantalla %s" % view)
	menu.queue_free()
	root.size = Vector2i(1280, 720)
	root.content_scale_size = root.size
	await step(2)
	main = load("res://game/boot/forest_boss.tscn").instantiate()
	main.collection_progress = CollectionProgress.new(storage + ".collection")
	root.add_child(main)
	main.progress = progress
	stage = main.stage
	arena = stage as ForestBossStage
	hero = main.player
	boss = arena.boss
	boss.defeated.connect(func(): wins += 1)
	await step(10)
	check(arena.checkpoint_positions().is_empty() and arena.level_keys.is_empty(), "El claro no añade un cuarto farol ni otras tres llaves")
	check(arena.pine_stations.size() == 2 and not main._keys_card.visible, "Dos fuentes renovables y HUD de jefe")
	check(not boss.has_method("receive_stomp"), "Nudor no admite daño por pisotón")
	for view in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(1024, 768)]:
		root.size = view
		root.content_scale_size = view
		await step(3)
		check(main._boss_bar.get_global_rect().end.x <= view.x and main._boss_bar.size.x >= 300, "HUD del jefe dentro de pantalla %s" % view)
	root.size = Vector2i(1280, 720)
	root.content_scale_size = root.size
	var clock: float = boss.state_seconds
	paused = true
	await step(30)
	check(is_equal_approx(clock, boss.state_seconds), "Pausa congela el reloj del ataque")
	paused = false
	hero.invulnerability = 10000
	hero.respawn(Vector2(400, 600))
	hero.invulnerability = 10000
	check(await wait_state(NudorBoss.State.SLAM_WARNING), "Primera acción: manotazo anunciado")
	var target_x: float = boss.slam_x
	hero.position.x = 650
	await step(35)
	check(is_equal_approx(target_x, boss.slam_x), "El aviso fija el golpe y permite apartarse")
	check(await wait_state(NudorBoss.State.OPEN), "El manotazo abre la bellota")
	var object: ThrowableObject = arena.pine_stations[0]
	var health: int = boss.health
	boss.receive_thrown_hit(object)
	check(boss.health == health, "Un objeto libre no daña al jefe")
	object.pick_up(hero.hand)
	boss.receive_thrown_hit(object)
	check(boss.health == health, "Un objeto sostenido no daña al jefe")
	object.release(1, Vector2.ZERO)
	object.set_physics_process(false)
	object.global_position = boss.global_position + Vector2(-99, -190)
	object.velocity = Vector2.ZERO
	boss.receive_thrown_hit(object)
	check(boss.health == health, "Un lanzamiento sin velocidad no causa daño")
	object.velocity = Vector2(760, 0)
	object._flight_time = object.definition.flight_seconds + 1
	boss.receive_thrown_hit(object)
	check(boss.health == health, "Un lanzamiento caducado no causa daño")
	object._flight_time = 0
	object.global_position.y = boss.global_position.y - 50
	boss.receive_thrown_hit(object)
	check(boss.health == health, "Golpear las raíces no daña la bellota")
	object.global_position.y = boss.global_position.y - 190
	boss.receive_thrown_hit(object)
	boss.receive_thrown_hit(object)
	check(boss.health == health - 1, "Un lanzamiento válido da un solo impacto por apertura")
	check(await wait_state(NudorBoss.State.OPEN), "Segundo ataque: barrido seguido de apertura")
	boss.receive_thrown_hit(object)
	check(boss.health == health - 1, "El mismo lanzamiento no se reutiliza en otra ventana")
	object.set_physics_process(true)
	object.reset_to_spawn()
	# Caer sobre el cuerpo no quita resistencia al jefe ni ofrece un pisotón.
	hero.respawn(boss.global_position + Vector2(0, -420))
	hero.invulnerability = 10000
	await step(75)
	check(boss.health == health - 1, "Contacto físico desde arriba no daña a Nudor")
	hero.respawn(Vector2(400, 600))
	hero.invulnerability = 10000
	# Todos los estados de ataque se limpian al reintentar; no se conserva una fase.
	for state_to_reset in [NudorBoss.State.SLAM_WARNING, NudorBoss.State.SLAM, NudorBoss.State.SWEEP_WARNING, NudorBoss.State.SWEEP, NudorBoss.State.OPEN]:
		check(await wait_state(state_to_reset), "Alcanzar estado de reintento %d" % state_to_reset)
		hero._die()
		main._resume()
		await step(2)
		hero.invulnerability = 10000
		check(not hero.dead and boss.health == 5 and boss.state == NudorBoss.State.INTRO and not boss._attack_art.visible, "Muerte/reintento limpia salud, aviso y ataque %d" % state_to_reset)
	# Sin invulnerabilidad, la presentación y las aperturas no causan daño.
	hero.respawn(Vector2(600, 600))
	hero.invulnerability = 0
	var before: int = hero.health
	await step(20)
	check(hero.health == before, "Presentación sin daño")
	# Daño real del manotazo, salto sobre el barrido y espacio seguro exterior.
	hero.invulnerability = 10000
	check(await wait_state(NudorBoss.State.SLAM_WARNING), "Esperar aviso para comprobar evasión")
	hero.position = Vector2(boss.slam_x + 250, 600)
	hero.invulnerability = 0
	before = hero.health
	await step(130)
	check(hero.health == before, "Apartarse del manotazo evita daño")
	hero.invulnerability = 10000
	check(await wait_state(NudorBoss.State.SLAM_WARNING), "Nuevo aviso de manotazo para daño físico")
	hero.position = Vector2(boss.slam_x, 600)
	hero.invulnerability = 0
	before = hero.health
	await step(125)
	check(hero.health == before - 1, "Quedarse dentro del manotazo quita un corazón")
	hero.invulnerability = 10000
	check(await wait_state(NudorBoss.State.SWEEP), "Barrido visible recorriendo el suelo")
	hero.position = Vector2(600, 600)
	hero.velocity = Vector2.ZERO
	while boss.sweep_x > 800:
		await step(1)
	hero.invulnerability = 0
	before = hero.health
	hero.controls.request_tap_jump()
	await step(55)
	check(hero.health == before and not hero.dead, "Un salto real evita el barrido al cruzar las raíces")
	hero.invulnerability = 10000
	await wait_state(NudorBoss.State.OPEN)
	check(await wait_state(NudorBoss.State.SWEEP), "Segundo barrido para comprobar contacto físico")
	hero.position = Vector2(600, 600)
	hero.velocity = Vector2.ZERO
	hero.invulnerability = 0
	before = hero.health
	await step(80)
	check(hero.health == before - 1, "No saltar el barrido quita un corazón")
	# Fallar ambas piñas no agota el combate.
	arena.respawn_player()
	hero.invulnerability = 10000
	for pine in arena.pine_stations:
		pine.global_position = Vector2(-500, 900)
	await step(10)
	check(arena.pine_stations[0].state == ThrowableObject.State.FREE and arena.pine_stations[1].state == ThrowableObject.State.FREE, "Ambas piñas perdidas vuelven al claro")
	# Cinco lanzamientos reales: recoger, esperar, saltar y soltar desde la mano.
	for hit in 5:
		hero.respawn(Vector2(760, 600))
		hero.invulnerability = 10000
		arena.pine_stations[1].reset_to_spawn()
		await step(20)
		hero.controls.set_virtual_axis(1)
		await step(1)
		hero.controls.set_virtual_axis(0)
		await pulse(&"grab_throw")
		if not check(is_instance_valid(hero.held_object), "Recogida real de la piña %d" % (hit + 1)):
			_finish()
			return
		if not check(await wait_state(NudorBoss.State.OPEN), "Ventana de lanzamiento %d" % (hit + 1)):
			_finish()
			return
		hero.controls.request_tap_jump()
		await step(4)
		await pulse(&"grab_throw", 60)
		if not check(boss.health == 4 - hit, "Lanzamiento aéreo físico impacta bellota %d" % (hit + 1)):
			print("OBJETO ", arena.pine_stations[1].position, " estado ", arena.pine_stations[1].state, " HERO ", hero.position)
			_finish()
			return
	check(arena.completed and wins == 1 and hero.celebrating, "Victoria única detiene daño y celebra")
	check(progress.is_completed("world_01_boss"), "Victoria se guarda separada de la tercera aventura")
	await step(100)
	check(wins == 1, "La celebración no repite la victoria")
	_finish()
