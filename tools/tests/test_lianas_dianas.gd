extends SceneTree
## Regresión del balanceo real: agarrar saltando, viajar colgado, soltar,
## volver a agarrar otra liana y recuperar la caída sin bloqueo.

var failures: int = 0
var checks: int = 0


func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
	print("%s %s" % ["OK" if ok else "FALLO", message])


func _initialize() -> void:
	_run.call_deferred()


func step(frames: int) -> void:
	for i in frames:
		await physics_frame
		await process_frame


func _run() -> void:
	var main = preload("res://game/boot/main.tscn").instantiate()
	root.add_child(main)
	await step(7)
	var stage: ForestStage = main.stage
	var hero: DiegoPlayer = main.player
	var crossing: ForestVineCrossing = stage.vine_crossings[0]
	check(stage.vine_crossings.size() == 1 and crossing.vines.size() == 5,
		"un barranco con cinco lianas independientes y móviles")
	check(stage.DEFINITION.region_names.size() == 10 and stage.level_keys.size() == 3,
		"nivel corto, con las tres llaves originales")
	for enemy in stage.enemies:
		enemy.set_physics_process(false)
		enemy.collision_layer = 0
		enemy._contact.monitoring = false
		enemy._stomp.collision_layer = 0
	var first: ForestSwingingVine = crossing.vines[0]
	var next: ForestSwingingVine = crossing.vines[1]
	var old_grip: Vector2 = first.grip_global_position()
	var old_second_grip: Vector2 = next.grip_global_position()
	await step(45)
	check(first.grip_global_position().distance_to(old_grip) > 15,
		"la primera liana oscila físicamente aun sin jugador")
	var second_moved: bool = next.grip_global_position().distance_to(old_second_grip) > 15
	for frame in 95:
		await step(1)
		if next.grip_global_position().distance_to(old_second_grip) > 35:
			second_moved = true
			break
	check(second_moved, "la segunda liana oscila con una fase distinta")
	check(absf(first.angle - next.angle) > 0.05,
		"las lianas no se desplazan en bloque")

	# El primer salto se produce desde la orilla sólida.
	hero.respawn(first.global_position + Vector2(-75, 490))
	hero.invulnerability = 10000.0
	hero.controls.set_virtual_axis(1.0)
	hero.controls.set_virtual_action(&"jump", true)
	var grabbed: bool = false
	for frame in 100:
		await step(1)
		if hero.attached_vine == first:
			grabbed = true
			break
	check(grabbed, "Diego salta y agarra la primera liana en el aire")
	hero.controls.set_virtual_action(&"jump", false)
	hero.controls.set_virtual_axis(0.0)
	if grabbed:
		var initial_x: float = hero.global_position.x
		await step(42)
		check(hero.attached_vine == first and absf(hero.global_position.x - initial_x) > 12,
			"Diego se desplaza con la liana sin quedar fijo")
		check((hero.global_position + DiegoPlayer.VINE_HAND_OFFSET).distance_to(first.grip_global_position()) < 2,
			"las manos siguen exactamente el nudo móvil")
		# Saltar de la cuerda transmite impulso; el agarre antiguo se bloquea brevemente.
		hero.controls.set_virtual_axis(1.0)
		hero.controls.set_virtual_action(&"jump", true)
		await step(2)
		check(hero.attached_vine == null and hero.velocity.y < -300.0,
			"otro salto libera la liana y da impulso vertical")
		check(hero.velocity.x > 110, "la dirección se combina con la velocidad real de la oscilación")
		hero.controls.set_virtual_action(&"jump", false)
		var released_speed: float = hero.velocity.x
		hero.controls.set_virtual_axis(0.0)
		await step(5)
		check(absf(hero.velocity.x - released_speed) < 1.0,
			"soltar el arrastre durante el vuelo conserva el impulso de la liana")
		hero.controls.set_virtual_axis(1.0)
		# Segunda liana: aproximarse en vuelo para verificar un nuevo agarre.
		hero.global_position = next.grip_global_position() - DiegoPlayer.VINE_HAND_OFFSET + Vector2(-35, 6)
		hero.velocity = Vector2(180, -80)
		await step(3)
		check(hero.attached_vine == next, "es posible enganchar la siguiente liana durante el salto")
		hero.controls.clear_virtual()

	# Un nudo lejano ya no atrae al personaje con un salto de posición.
	hero.respawn(first.grip_global_position() - DiegoPlayer.VINE_HAND_OFFSET + Vector2(118, 0))
	var before_grab: Vector2 = hero.global_position
	hero._try_grab_swinging_vine(hero.global_position + DiegoPlayer.VINE_HAND_OFFSET)
	check(hero.attached_vine == null and hero.global_position == before_grab,
		"una liana fuera del alcance de las manos no teletransporta al jugador")
	stage.respawn_player()
	check(hero.attached_vine == null, "reaparecer suelta la liana sin dejar al jugador bloqueado")
	check(first.grip_velocity == Vector2.ZERO and next.grip_velocity == Vector2.ZERO,
		"las lianas reinician su ciclo sin enganchar al jugador")
	check(stage.level_keys.size() == 3, "la salida sigue requiriendo tres llaves")
	main.queue_free()
	await step(3)
	print("LIANAS OSCILANTES: %d comprobaciones, %d fallos" % [checks, failures])
	await preload("res://tools/tests/audio_cleanup.gd").flush(self)
	quit(0 if failures == 0 else 1)
