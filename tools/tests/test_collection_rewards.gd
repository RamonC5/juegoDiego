extends SceneTree
## Contratos de guardado real, duplicación, vestuario, pausa y recuperación.

var checks: int = 0
var failures: int = 0
var storage: String = "user://collection-regression-%d.json" % OS.get_process_id()


func _initialize() -> void:
	_run.call_deferred()


func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
	print("%s %s" % ["OK" if condition else "FALLO", label])


func step(frames: int = 3) -> void:
	for index in frames:
		await physics_frame
		await process_frame


func cleanup(path: String) -> void:
	for suffix in ["", ".tmp", ".bak"]:
		DirAccess.remove_absolute(path + suffix)


func _run() -> void:
	cleanup(storage)
	var profile := CollectionProgress.new(storage)
	check(profile.count("leaf") == 0 and profile.equipped == "original", "perfil nuevo con traje original")
	check(not profile.helper_unlocked() and not profile.is_unlocked("golden_forest") and not profile.is_unlocked("ladybug_hero") and not profile.is_unlocked("ladybug_legend"), "ayudante y traje especial empiezan bloqueados")
	check(not profile.equip("forest_explorer"), "no permite equipar un traje bloqueado")
	check(not profile.collect_item("test", "forged", "leaf"), "rechaza identificadores ajenos al manifiesto")
	var manifest: Dictionary = {}
	for i in 100:
		manifest["leaf-%d" % i] = "leaf"
	profile.register_level("test", manifest)
	for i in 11:
		profile.collect_item("test", "leaf-%d" % i, "leaf")
	check(not profile.is_unlocked("autumn_scarf"), "once hojas aún no desbloquean el pañuelo")
	profile.collect_item("test", "leaf-11", "leaf")
	check(profile.is_unlocked("autumn_scarf") and profile.count("leaf") == 12, "doce hojas desbloquean la primera prenda")
	check(not profile.collect_item("test", "leaf-11", "leaf") and profile.count("leaf") == 12, "una hoja solo cuenta una vez")
	check(not profile.collect_item("test", "leaf-12", "crystal"), "no acepta alterar el tipo del objeto")
	for i in range(12, 100):
		profile.collect_item("test", "leaf-%d" % i, "leaf")
	check(profile.is_unlocked("fern_vest") and profile.is_unlocked("forest_explorer"), "45 y 100 hojas desbloquean chaleco y explorador")
	check(not profile.is_unlocked("ladybug_hero") and not profile.equip("ladybug_hero"), "100 hojas no bastan para el traje épico")
	check(profile.next_reward().id == "ladybug_hero", "el siguiente hito anuncia el traje Ladybug épico")
	check(profile.equip("fern_vest") and profile.count("leaf") == 100, "equipar no gasta hojas")
	var reopened := CollectionProgress.new(storage)
	check(reopened.count("leaf") == 100 and reopened.equipped == "fern_vest", "cerrar y reabrir conserva hojas y ropa equipada")
	check(not reopened.equip("unknown"), "identificador desconocido no sustituye el traje")
	var fragments: Dictionary = {}
	for id in CollectionRewards.FRAGMENT_IDS:
		fragments[CollectionRewards.FOREST_ID + "/fragment/" + id] = "fragment"
	fragments["forest-leaf"] = "leaf"
	fragments["forest-crystal"] = "crystal"
	reopened.register_level(CollectionRewards.FOREST_ID, fragments)
	for id in CollectionRewards.FRAGMENT_IDS:
		reopened.collect_item(CollectionRewards.FOREST_ID, CollectionRewards.FOREST_ID + "/fragment/" + id, "fragment")
	check(reopened.helper_unlocked(), "los tres fragmentos despiertan al ayudante")
	check(reopened.is_unlocked("ladybug_hero") and reopened.equip("ladybug_hero"), "100 hojas y tres fragmentos desbloquean y permiten equipar Ladybug")
	check(CollectionProgress.new(storage).equipped == "ladybug_hero", "el traje épico se guarda sin cambiar el esquema")
	check(not reopened.is_unlocked("golden_forest") and not reopened.is_unlocked("ladybug_legend"), "los fragmentos no conceden la variante legendaria")
	reopened.collect_item(CollectionRewards.FOREST_ID, "forest-leaf", "leaf")
	reopened.collect_item(CollectionRewards.FOREST_ID, "forest-crystal", "crystal")
	check(reopened.is_unlocked("golden_forest"), "colección completa desbloquea la variante dorada")
	check(reopened.is_unlocked("ladybug_legend") and reopened.equip("ladybug_legend"), "colección completa desbloquea y equipa Ladybug estelar")
	check(CollectionProgress.new(storage).equipped == "ladybug_legend", "el traje legendario sobrevive a reabrir el juego")
	check(reopened.unlocked_outfits().size() == CollectionRewards.OUTFITS.size(), "no quedan recompensas de ropa pendientes tras completar la colección")
	reopened.set_helper_enabled(false)
	check(not CollectionProgress.new(storage).helper_enabled, "preferencia del ayudante guardada")
	var file := FileAccess.open(storage, FileAccess.WRITE)
	file.store_string("archivo incompleto")
	file.close()
	var recovered := CollectionProgress.new(storage)
	check(recovered.count("leaf") == 101 and recovered.helper_unlocked(), "archivo dañado se recupera desde copia válida")
	file = FileAccess.open(storage, FileAccess.WRITE)
	file.store_string('{"schema_version":1,"collected":{"bad":{"level":"test","kind":"invalid"}}}')
	file.close()
	var semantic_recovery := CollectionProgress.new(storage)
	semantic_recovery.equip("original")
	var backup := CollectionProgress.new(storage + ".bak")
	check(backup.count("leaf") == 101, "un archivo inválido no sustituye la copia válida al volver a guardar")
	var failing := CollectionProgress.new("user://directorio-inexistente-%d/save.json" % OS.get_process_id())
	failing.register_level("test", {"leaf": "leaf"})
	check(not failing.collect_item("test", "leaf", "leaf") and failing.count("leaf") == 0, "fallo de disco no concede progreso sin guardar")

	var game_path: String = storage + "-game"
	cleanup(game_path)
	var main = preload("res://game/boot/main.tscn").instantiate()
	main.collection_progress = CollectionProgress.new(game_path)
	root.add_child(main)
	await step(6)
	var stage: ForestStage = main.stage
	var hero: DiegoPlayer = main.player
	for enemy in stage.enemies:
		enemy.set_physics_process(false)
		enemy.collision_layer = 0
		enemy._contact.monitoring = false
	check(stage.fragments.size() == 3 and is_instance_valid(stage.firefly), "bosque integra tres fragmentos y nido del ayudante")
	var ids: Dictionary = {}
	for item in stage.collectibles:
		ids[item.persistent_id] = true
	check(ids.size() == stage.collectibles.size(), "todas las hojas y cristales tienen IDs únicos")
	check(stage.total_leaves > 100, "el nivel permite obtener las tres prendas")
	var leaf: ForestCollectible = stage.collectibles[0]
	hero.respawn(leaf.position + Vector2(0, 45))
	await step(6)
	check(leaf.taken and main.collection_progress.has_item(leaf.persistent_id), "contacto físico guarda la hoja inmediatamente")
	var before: int = main.collection_progress.count("leaf")
	leaf._on_body_entered(hero)
	check(main.collection_progress.count("leaf") == before, "contacto repetido no duplica la moneda permanente")
	for item in stage.collectibles:
		if main.collection_progress.count("leaf") >= 12:
			break
		if not item.crystal:
			item._on_body_entered(hero)
	check(main._reward_toast.visible, "el primer desbloqueo muestra confirmación con acceso a la colección")
	main._open_wardrobe()
	await step()
	check(paused and main._collection_menu.visible and not hero.controls.enabled, "vestuario pausa el juego y libera controles")
	check(main._collection_menu._actions["forest_explorer"].disabled, "el menú conserva bloqueadas las prendas pendientes")
	main._collection_menu._equip("autumn_scarf")
	check(main.collection_progress.equipped == "autumn_scarf" and int(hero.sprite.material.get_shader_parameter("outfit")) == 1, "equipar desde menú aplica el material real de Diego")
	check(hero.sprite.material != main._collection_menu._preview.material, "previsualización y jugador no comparten material mutable")
	main._toggle_pause()
	check(paused and not main._collection_menu.visible and main._menu.visible, "Escape vuelve del vestuario a la pausa")
	main._resume()
	await step()
	check(not paused and hero.controls.enabled and main.touch._pointers.is_empty(), "continuar limpia contactos y restaura controles")
	for fragment in stage.fragments:
		hero.respawn(fragment.position + Vector2(0, 45))
		fragment._on_body_entered(hero)
	check(main.collection_progress.helper_unlocked() and stage.firefly.awake, "recoger los tres fragmentos despierta a Luci durante la partida")
	await step(5)
	var phase: float = stage.firefly._phase
	main._open_menu("Pausa")
	await step(5)
	check(stage.firefly._phase == phase, "el aleteo respeta la pausa")
	main._resume()
	hero.respawn(stage.DEFINITION.secret_grove + Vector2(-240, 0))
	await step(4)
	check(stage.firefly.hinting, "señal de proximidad al secreto")
	main.collection_progress.set_helper_enabled(false)
	check(not stage.firefly.visible, "el compañero puede descansar sin borrar el desbloqueo")
	main.collection_progress.set_helper_enabled(true)
	stage.respawn_player()
	await step()
	check(leaf.taken and stage.fragments[0].taken and main.collection_progress.is_unlocked("autumn_scarf"), "morir conserva coleccionables y recompensas")
	check(stage.firefly.position.distance_to(hero.position) < 200, "ayudante vuelve junto al protagonista tras reaparecer")
	var id: String = leaf.persistent_id
	main.queue_free()
	await step(4)
	var replay = preload("res://game/boot/main.tscn").instantiate()
	replay.collection_progress = CollectionProgress.new(game_path)
	root.add_child(replay)
	await step(4)
	check(replay.stage.collectibles[0].taken and replay.collection_progress.has_item(id), "nueva escena conserva la colección sin volver a conceder hojas")
	check(replay.stage.collected_keys.is_empty() and replay.stage.activated_mechanisms.is_empty(), "rejugar mantiene el reinicio de llaves y mecanismos del intento")
	check(replay.collection_progress.equipped == "autumn_scarf" and replay.stage.firefly.awake, "ropa y ayudante sobreviven al cierre de la escena")
	replay.queue_free()
	await step(4)
	cleanup(storage)
	cleanup(game_path)
	print("COLECCIÓN: %d comprobaciones, %d fallos" % [checks, failures])
	await preload("res://tools/tests/audio_cleanup.gd").flush(self)
	quit(0 if failures == 0 else 1)
