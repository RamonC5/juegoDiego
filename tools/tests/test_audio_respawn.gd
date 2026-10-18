extends SceneTree
## Recuperación con instancias liberadas, progreso conservado, audio y símbolos.

var failures: int = 0
var checks: int = 0
var main: Node2D


func _initialize() -> void:
	_run.call_deferred()


func step(frames: int = 2) -> void:
	for index in frames:
		await physics_frame
		await process_frame


func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
	print("%s %s" % ["OK" if condition else "FALLO", description])


func freeze_enemies(stage: ForestStage) -> void:
	for enemy in stage.enemies:
		if is_instance_valid(enemy):
			enemy.set_physics_process(false)


func _run() -> void:
	main = load("res://game/boot/main.tscn").instantiate()
	main.collection_progress = CollectionProgress.new("user://collection-test_audio_respawn-%d-%d.json" % [OS.get_process_id(), Time.get_ticks_usec()])
	root.add_child(main)
	await step(3)
	var stage: ForestStage = main.stage
	var hero: DiegoPlayer = main.player
	freeze_enemies(stage)
	check(main._music.playing and main._music.stream == stage.DEFINITION.music_stream, "el bosque arranca con su pista asignada")
	var track := main._music.stream as AudioStreamOggVorbis
	check(track != null and track.loop and track.get_length() > 70.0, "pista instrumental completa en bucle")
	check(track != null and is_equal_approx(track.bpm, 128.0) and track.beat_count == 192, "la importación usa el tema nuevo de 128 BPM y 48 compases")
	check(main._music.bus == &"Music" and AudioServer.get_bus_index(&"Music") >= 0, "bus musical independiente")
	check(main._music.process_mode == Node.PROCESS_MODE_PAUSABLE, "audio sujeto a pausa, derrota y pérdida de foco")
	var old_volume: float = main.settings.music_volume
	main.settings.music_volume = 0.0
	main._apply_settings()
	check(main._music.volume_db <= -79.0, "cero silencia la música")
	main.settings.music_volume = old_volume
	main._apply_settings()
	check(main._music.volume_db > -79.0, "el volumen se restaura sin reiniciar la pista")
	main._open_menu("Pausa", true)
	await step(3)
	check(paused and main._music.stream_paused, "abrir la pausa suspende la reproducción")
	main._resume()
	await step(3)
	check(not paused and main._music.playing and not main._music.stream_paused, "continuar reanuda la misma voz")
	var track_id: int = main._music.get_instance_id()
	main._music.play_track(track)
	check(main._music.get_instance_id() == track_id, "solicitar la misma pista no duplica reproductores")

	# Antes de activar faroles también se repone una derrota por pisotón.
	var first: ForestEnemy = stage.enemies[0]
	first.defeat(false)
	await step(45)
	check(not is_instance_valid(first), "la animación libera al enemigo derrotado")
	stage.respawn_player()
	freeze_enemies(stage)
	check(is_instance_valid(stage.enemies[0]) and stage.enemies[0].active, "morir antes del primer farol repone la derrota")
	check(stage.defeated_enemies == 0, "reintentar no acumula derrotas repetidas")
	var committed: ForestEnemy = stage.enemies[1]
	committed.defeat(false)
	stage._on_checkpoint(hero, 0)
	check(stage.defeated_enemies == 1 and stage._defeated_since_checkpoint.is_empty(), "el nuevo farol consolida las derrotas anteriores")
	stage.level_keys[0]._on_body_entered(hero)
	var station: ForestThrowTarget = stage.throw_targets[0]
	station.restore_activated()
	stage._on_mechanism_activated(station.definition.mechanism_id)
	var leaves_before: int = stage.leaves
	var crystals_before: int = stage.crystals
	stage.enemies[2].defeat(false)
	stage.enemies[3].defeat(true)
	await step(45)
	var pending: ForestEnemy = stage.enemies[4]
	pending.defeat(true)
	var pending_id: int = pending.get_instance_id()
	# Una derrota se repone mientras su tween todavía está activo.
	hero.dead = true
	stage.respawn_player()
	freeze_enemies(stage)
	await step(2)
	check(not is_instance_valid(committed) or not committed.active, "el enemigo derrotado antes del farol permanece eliminado")
	for index in [2, 3, 4]:
		var restored: ForestEnemy = stage.enemies[index]
		check(restored.active and restored.spawn_index == index, "se reconstruye la patrulla %d por su índice estable" % index)
		check(restored.position.distance_to(Vector2(stage.DEFINITION.enemy_spawns[index].x, stage.DEFINITION.enemy_spawns[index].y)) < 1.0, "la patrulla %d vuelve a su puesto original" % index)
	check(not is_instance_id_valid(pending_id), "el cuerpo con derrota pendiente se elimina antes de reconstruirlo")
	check(stage.defeated_enemies == 1 and stage.enemies.size() == 45, "sin duplicar patrullas ni inflar el marcador")
	check(not hero.dead and hero.health == 3 and hero.position.distance_to(stage.respawn_position) < 2.0, "Diego recupera energía y vuelve al farol")
	check(stage.collected_keys.has(0) and stage.leaves == leaves_before and stage.crystals == crystals_before, "se conservan llaves y coleccionables")
	check(stage.activated_mechanisms.is_empty() and station.active and station._sprite.visible and stage.bridges[0].state == RootBridge.State.CLOSED, "se cierran mecanismos y se reconstruyen las dianas al reaparecer")
	check(main._music.get_instance_id() == track_id, "reaparecer conserva un único reproductor")
	var stable_id: int = stage.enemies[2].get_instance_id()
	stage.respawn_player()
	freeze_enemies(stage)
	check(stage.enemies[2].get_instance_id() == stable_id, "reaparecer otra vez sin derrotas nuevas no duplica enemigos")
	stage._on_checkpoint(hero, 1)
	stage.enemies[2].defeat(true)
	stage._on_checkpoint(hero, 0)
	check(stage.active_checkpoint_index == 1 and stage._defeated_since_checkpoint.has(2), "un farol anterior no consolida derrotas nuevas ni retrocede el punto")
	stage.respawn_player()
	freeze_enemies(stage)
	check(stage.enemies[2].active, "también se restaura un enemigo derrotado al volver atrás")
	check(stage.active_checkpoint_index == 1, "el farol conserva su estado sin insignias flotantes")
	check(not _has_letters(stage), "el escenario no contiene rótulos con letras")
	check(not main._message.visible and not _has_letters(main.touch), "la partida queda libre de guías y mensajes superpuestos")
	main.queue_free()
	await step(2)
	main = load("res://game/boot/main.tscn").instantiate()
	main.collection_progress = CollectionProgress.new("user://collection-test_audio_respawn-%d-%d.json" % [OS.get_process_id(), Time.get_ticks_usec()])
	root.add_child(main)
	await step(2)
	check(main.stage.defeated_enemies == 0 and main.stage.enemies.size() == 45, "reiniciar el nivel crea todas las patrullas de nuevo")
	main.queue_free()
	await step(2)
	print("Audio y reaparición: %d comprobaciones, %d fallos" % [checks, failures])
	await preload("res://tools/tests/audio_cleanup.gd").flush(self)
	quit(1 if failures else 0)


func _has_letters(node: Node) -> bool:
	if node is Label and node.visible:
		var pattern := RegEx.new()
		pattern.compile("[A-Za-zÁÉÍÓÚáéíóúÑñ]")
		if pattern.search(node.text) != null:
			return true
	for child in node.get_children():
		if _has_letters(child):
			return true
	return false

