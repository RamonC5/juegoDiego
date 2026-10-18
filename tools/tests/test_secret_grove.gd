extends SceneTree
## Regresión del secreto opcional: trampilla, recompensa, ascensor y reaparición.

var checks: int = 0
var failures: int = 0


func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
	print("%s %s" % ["OK" if ok else "FALLO", label])


func _initialize() -> void:
	_run.call_deferred()


func step(frames: int) -> void:
	for i in frames:
		await physics_frame
		await process_frame


func _run() -> void:
	var main = preload("res://game/boot/main.tscn").instantiate()
	main.collection_progress = CollectionProgress.new("user://collection-test_secret_grove-%d-%d.json" % [OS.get_process_id(), Time.get_ticks_usec()])
	root.add_child(main)
	await step(8)
	var stage: ForestStage = main.stage
	var hero: DiegoPlayer = main.player
	var grove: ForestSecretGrove = stage.secret_grove
	check(is_instance_valid(grove), "la gruta se construye desde los datos del bosque")
	if not is_instance_valid(grove):
		quit(1)
		return
	check(grove.position == Vector2(11610, 600) and stage.level_keys.size() == 3,
		"secreto antes de las llaves sin cambiar su recorrido obligatorio")
	var secret_gap: float = 0.0
	for i in stage.DEFINITION.ground_sections.size() - 1:
		var edge: float = stage.DEFINITION.ground_sections[i].end.x
		if is_equal_approx(edge, 11520.0):
			secret_gap = stage.DEFINITION.ground_sections[i + 1].position.x - edge
	check(is_equal_approx(secret_gap, 180.0),
		"la entrada oculta no introduce un barranco inaccesible en el recorrido obligatorio")
	check(stage.moving_platforms.size() == 5 and is_instance_valid(grove.lift),
		"ascensor independiente de los cinco troncos de la ruta")
	check(grove.lift.z_index > 0, "el ascensor se dibuja delante del fondo subterráneo")
	var totem: ForestSecretTotem = stage.secret_totem
	check(is_instance_valid(totem) and totem.position == grove.position + Vector2(-180, 0),
		"tótem propio en el borde izquierdo de la trampilla oculta")
	if is_instance_valid(totem):
		check(totem.get_child_count() == 0 and totem.z_index == 4,
			"el tótem es solo arte, sin colisión ni áreas que bloqueen el camino")
	for enemy in stage.enemies:
		enemy.set_physics_process(false)
		enemy.collision_layer = 0
		enemy._contact.monitoring = false
	hero.respawn(grove.global_position)
	await step(4)
	check(not grove.hatch_shape.disabled, "hojas sostienen al jugador sin agacharse")
	if is_instance_valid(totem):
		check(totem._nearby and totem._phase > 0.0,
			"hojas y resplandor del tótem se animan al acercarse Diego")
	hero.controls.set_virtual_action(&"crouch", true)
	await step(5)
	check(grove.hatch_shape.disabled, "agacharse abre el suelo falso sin nuevo botón")
	# Descenso y trayecto reales: no trasladar al héroe directamente hasta el premio.
	for frame in 90:
		await step(1)
		if hero.global_position.y > grove.global_position.y + 150.0:
			break
	hero.controls.clear_virtual()
	await step(70)
	check(hero.global_position.y > grove.global_position.y + 400.0 and not hero.dead,
		"la trampilla permite llegar realmente al suelo bajo el bosque")
	hero.controls.set_virtual_axis(-1.0)
	var traversed: float = hero.global_position.x
	for frame in 400:
		await step(1)
		if hero.global_position.x < grove.global_position.x + ForestSecretGrove.LIFT_X + 20.0:
			break
	hero.controls.clear_virtual()
	await step(15)
	check(traversed - hero.global_position.x > 1100.0 and not hero.dead,
		"se puede caminar más de mil píxeles bajo la tierra sin chocar con los bloques de superficie")
	check(grove.reward_taken and hero.maximum_health == 4 and hero.health == 4,
		"el brote se recoge al recorrer el túnel, sin teletransporte")
	# Esperar a que la plataforma vuelva abajo y saltar sobre ella desde el suelo.
	for frame in 700:
		await step(1)
		if grove.lift.position.y > 400.0:
			break
	hero.controls.set_virtual_action(&"jump", true)
	await step(30)
	hero.controls.clear_virtual()
	var surfaced: bool = false
	for frame in 650:
		await step(1)
		if hero.global_position.y < grove.global_position.y + 10.0:
			surfaced = true
			break
	check(surfaced and not hero.dead, "tras explorar, el ascensor del otro extremo permite atravesar el techo y salir")
	check(stage.leaves >= 0 and stage.collectibles.size() == stage.total_leaves + 3,
		"la hojarasca opcional se incluye en el recuento del bosque")
	grove._on_reward_body_entered(hero)
	check(hero.maximum_health == 4, "el premio no se puede duplicar")
	hero.take_damage(hero.global_position + Vector2(50, 0))
	hero.take_damage(hero.global_position + Vector2(50, 0))
	stage.respawn_player()
	await step(3)
	check(hero.maximum_health == 4 and hero.health == 4 and grove.reward_taken,
		"la vida extra permanece durante el intento al volver al farol")
	check(grove.lift.position.distance_to(grove.lift.definition.start_position) < 5.0,
		"el ascensor recupera su recorrido después de reaparecer")
	# Ascensor continuo: Diego lo alcanza desde el suelo y sale hacia arriba.
	hero.respawn(grove.global_position + Vector2(ForestSecretGrove.LIFT_X, 426))
	grove.lift.reset_cycle()
	await step(285)
	check(not hero.dead and hero.position.y < 790,
		"la plataforma lleva al jugador desde la gruta hacia la superficie")
	hero.respawn(Vector2(1450, 600))
	await step(4)
	if is_instance_valid(totem):
		check(not totem._nearby, "el tótem detiene la animación al alejarse para ahorrar recursos")
	check(hero.fall_limit_y == 980.0, "otros barrancos conservan el límite de caída anterior")
	main.queue_free()
	await step(3)
	print("GRUTA DE HOJAS: %d comprobaciones, %d fallos" % [checks, failures])
	await preload("res://tools/tests/audio_cleanup.gd").flush(self)
	quit(0 if failures == 0 else 1)

