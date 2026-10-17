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
	check(stage.moving_platforms.size() == 5 and is_instance_valid(grove.lift),
		"ascensor independiente de los cinco troncos de la ruta")
	for enemy in stage.enemies:
		enemy.set_physics_process(false)
		enemy.collision_layer = 0
		enemy._contact.monitoring = false
	hero.respawn(grove.global_position)
	await step(4)
	check(not grove.hatch_shape.disabled, "hojas sostienen al jugador sin agacharse")
	hero.controls.set_virtual_action(&"crouch", true)
	await step(5)
	check(grove.hatch_shape.disabled, "agacharse abre el suelo falso sin nuevo botón")
	hero.controls.clear_virtual()
	hero.respawn(grove.reward_zone.global_position + Vector2(0, 22))
	await step(5)
	check(grove.reward_taken and hero.maximum_health == 4 and hero.health == 4,
		"recoger el brote suma una vida a la energía máxima")
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
	hero.respawn(Vector2(1450, 600))
	await step(4)
	check(hero.fall_limit_y == 980.0, "otros barrancos conservan el límite de caída anterior")
	main.queue_free()
	await step(3)
	print("GRUTA DE HOJAS: %d comprobaciones, %d fallos" % [checks, failures])
	await preload("res://tools/tests/audio_cleanup.gd").flush(self)
	quit(0 if failures == 0 else 1)
