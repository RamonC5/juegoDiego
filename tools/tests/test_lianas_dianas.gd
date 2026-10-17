extends SceneTree
## Regresión aislada del ascenso, rebote, rotura y recuperación local.

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
	var main := preload("res://game/boot/main.tscn").instantiate()
	root.add_child(main)
	await step(7)
	var stage: ForestStage = main.stage
	var hero: DiegoPlayer = main.player
	check(stage.vine_crossings.size() == 1, "un barranco de liana y dianas")
	check(stage.vine_crossings[0].targets.size() == 5, "cinco puntos elásticos de paso")
	var crossing: ForestVineCrossing = stage.vine_crossings[0]
	check(stage.DEFINITION.region_names.size() == 10, "el bosque tiene diez tramos, no diecinueve")
	check(stage.level_keys.size() == 3, "las tres llaves siguen presentes")
	for enemy in stage.enemies:
		enemy.set_physics_process(false)
		enemy.collision_layer = 0
		enemy._contact.monitoring = false
	hero.respawn(Vector2(crossing.position.x + ForestVineCrossing.VINE_X, 595))
	hero.controls.set_virtual_action(&"jump", true)
	await step(40)
	check(hero.position.y < 460, "mantener salto junto a la liana permite ascender")
	hero.controls.clear_virtual()
	var target: ForestVineTarget = crossing.targets[0]
	hero.set_physics_process(false)
	hero.respawn(target.global_position + Vector2(0, -20))
	target.bounce(hero)
	check(not target.intact and hero.velocity.y < -700, "la diana se rompe e impulsa a Diego")
	target.reset_target()
	check(target.intact, "el cristal se recompone al recuperar el tramo")
	stage.respawn_player()
	check(crossing.targets.all(func(t: ForestVineTarget) -> bool: return t.intact), "la muerte rearma todas las dianas del barranco")
	main.queue_free()
	await step(3)
	print("LIANAS Y DIANAS: %d comprobaciones, %d fallos" % [checks, failures])
	await preload("res://tools/tests/audio_cleanup.gd").flush(self)
	quit(0 if failures == 0 else 1)
