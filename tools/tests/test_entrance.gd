extends SceneTree
## Flujo real de escenas, bloqueo de mundos, movimiento reducido y retorno desde pausa.

var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)


func frames(count: int = 4) -> void:
	for index in count:
		await process_frame


func tap(control: Control) -> void:
	var position: Vector2 = control.get_global_rect().get_center()
	for down in [true, false]:
		var event := InputEventScreenTouch.new()
		event.position = position
		event.index = 0
		event.pressed = down
		Input.parse_input_event(event)
		await process_frame


func _run() -> void:
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1280, 720)
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://game/boot/entrance.tscn", "La aplicación arranca en la nueva entrada")
	check(WorldCatalog.WORLDS.size() == 8, "El mapa contiene ocho mundos")
	var ids: Array[String] = []
	var cells: Array[Vector2i] = []
	for index in WorldCatalog.WORLDS.size():
		var world: Dictionary = WorldCatalog.WORLDS[index]
		check(not ids.has(world.id), "Identificador único")
		check(not cells.has(world.cell), "Isla única en la ilustración")
		ids.append(world.id)
		cells.append(world.cell)
		check(WorldCatalog.scene_for(world.id).is_empty() == (index != 0), "Solo el bosque ofrece una ruta jugable")
	check(WorldCatalog.scene_for("desconocido").is_empty(), "Rechazar mundo desconocido")
	var entrance: Control = load("res://game/boot/entrance.tscn").instantiate()
	root.add_child(entrance)
	current_scene = entrance
	await frames()
	check(entrance.page == &"intro" and entrance.intro.visible, "Introducción visible al iniciar")
	check(not entrance.world_map.visible, "El mapa espera a Jugar ahora")
	check(root.find_children("BosqueEsmeralda", "", true, false).is_empty(), "El nivel no se inicia bajo la introducción")
	check(entrance.play_button.has_focus(), "Foco inicial en Jugar ahora")
	entrance.intro.set_reduced_motion(false)
	for index in WorldCatalog.WORLDS.size():
		entrance.intro.clock = index * AdventureIntro.BEAT_SECONDS + 0.5
		entrance.intro._process(0.0)
		check(entrance.intro.current_beat == index, "Montaje de cada aventura")
		check(entrance.intro.actor.animation == entrance.intro.sample_action(index, 0.5).pose, "Pose real de la secuencia")
		check(entrance.intro.actor.position.is_finite(), "Actor con posición válida")
	check(entrance._hero_title.visible and entrance._hero_title.accessibility_name == "Super Diego", "Título de superhéroe con nombre accesible")
	# Dos vueltas completas: cambios reales de miembros y acciones, sin saltos de raíz.
	entrance.intro.set_process(false)
	check(entrance.intro._frames.get_frame_count(&"run") == 8, "La entrada utiliza ocho poses de carrera propias")
	check(entrance.intro._island.texture.atlas == AdventureIntro.SCENES, "El decorado usa escenas y no recortes del mapa")
	for cycle in 2:
		for index in WorldCatalog.WORLDS.size():
			var poses: Dictionary = {}
			var frames_used: Dictionary = {}
			var previous_position := Vector2.ZERO
			for tick in range(int(AdventureIntro.BEAT_SECONDS * 60)):
				var seconds: float = tick / 60.0
				entrance.intro.clock = (cycle * 8 + index) * AdventureIntro.BEAT_SECONDS + seconds
				entrance.intro._process(0.0)
				var sprite: AnimatedSprite2D = entrance.intro.actor
				poses[sprite.animation] = true
				frames_used["%s:%d" % [sprite.animation, sprite.frame]] = true
				if tick > 1:
					check(sprite.position.distance_to(previous_position) < 24.0, "Trayectoria continua a 60 Hz")
				previous_position = sprite.position
			check(frames_used.size() >= 3 or index == 5, "Movimiento local de miembros con fotogramas reales")
			if index in [1, 4, 6, 7]:
				check(poses.size() >= 3, "Acción completa con preparación y recuperación")
	entrance.intro.clock = AdventureIntro.BEAT_SECONDS + 0.15
	entrance.intro._process(0.0)
	check(entrance.intro._island.modulate.a > 0.0 and entrance.intro._island.modulate.a < 1.0, "Fundido de mundos intermedio")
	entrance.intro.clock = 4 * AdventureIntro.BEAT_SECONDS + 2.75
	entrance.intro._process(0.0)
	check(not entrance.intro._prop.visible, "La vasija lanzada no vuelve a aparecer en la mano")
	# Caída, lanzamiento y aterrizaje recuperan carrera sin sostener el último dibujo.
	for world in [0, 1, 3, 4, 6, 7]:
		check(entrance.intro.sample_action(world, 3.1).pose == &"run", "La acción termina y recupera carrera")
	entrance.intro.clock = 1.0
	entrance.intro._process(0.0)
	check(entrance.intro.actor.modulate.a == 1.0, "El personaje tiene una única silueta opaca")
	var enemy_phase: float = entrance.intro._ground_enemy.phase
	entrance.intro._process(0.2)
	check(entrance.intro._ground_root.visible and entrance.intro._ground_enemy.phase != enemy_phase, "Moflete persigue con movimiento local de sus miembros")
	entrance.intro.clock = 4.0 * AdventureIntro.BEAT_SECONDS + 0.6
	entrance.intro._process(0.0)
	enemy_phase = entrance.intro._flying_enemy.phase
	entrance.intro._process(0.2)
	check(entrance.intro._flying_root.visible and entrance.intro._flying_enemy.phase != enemy_phase, "Nóctilo avanza el aleteo en la escena")
	# Un tirón del render no corta el tiempo ni deja la pose detenida.
	for rate in [30, 60, 120]:
		entrance.intro.restart()
		for tick in range(rate * 2):
			entrance.intro._process(1.0 / rate)
		check(entrance.intro.actor.position.is_finite() and is_equal_approx(entrance.intro.clock, 2.0), "Tiempo independiente de la tasa de fotogramas")
	entrance.intro._process(0.35)
	check(entrance.intro.sample_action(0, fmod(entrance.intro.clock, AdventureIntro.BEAT_SECONDS)).pose == &"land", "Un fotograma lento llega al aterrizaje sin atascar el estado")
	entrance.intro.set_reduced_motion(true)
	check(not entrance.intro._ground_root.visible and not entrance.intro._flying_root.visible, "Activar movimiento reducido oculta los malvados inmediatamente")
	var clock: float = entrance.intro.clock
	entrance.intro._process(2.0)
	check(entrance.intro.clock == clock and not entrance.intro.actor.is_playing(), "Movimiento reducido congela montaje y sprite")
	check(not entrance.intro._rope.visible and not entrance.intro._prop.visible, "Movimiento reducido detiene todos los adornos")
	check(not entrance.intro._ground_root.visible and not entrance.intro._flying_root.visible, "Movimiento reducido detiene los enemigos decorativos")
	entrance.settings.menu_reduced_motion = false
	entrance._toggle_motion()
	var persisted := ControlSettings.new()
	root.add_child(persisted)
	check(persisted.menu_reduced_motion, "La preferencia de movimiento se guarda")
	persisted.queue_free()
	await tap(entrance.play_button)
	await frames()
	check(entrance.page == &"map" and entrance.world_map.visible, "Toque Jugar ahora abre el mapa")
	check(not entrance._hero_title.visible and entrance._title.visible, "El mapa conserva su encabezado legible")
	check(entrance.world_map.world_buttons.size() == 8, "Ocho botones de mundo")
	for button in entrance.world_map.world_buttons:
		check(button.size.y >= 48 and not button.accessibility_name.is_empty(), "Botón táctil y nombre accesible")
	await tap(entrance.world_map.world_buttons[2])
	check(current_scene == entrance and entrance.page == &"map", "Tocar una isla bloqueada no carga un nivel")
	check(not entrance._loading, "Un mundo bloqueado no deja la pantalla cargando")
	for index in range(1, 8):
		entrance._request_world(WorldCatalog.WORLDS[index].id)
		check(current_scene == entrance, "El bloqueo se aplica a todos los mundos pendientes")
	Input.action_press(&"jump")
	await tap(entrance.world_map.world_buttons[0])
	await frames(12)
	var forest: Node2D = current_scene
	check(forest != entrance and is_instance_valid(forest.get("stage")), "Tocar el bosque abre su nivel real")
	check(forest.player.jumps_used == 0, "El toque de selección no se convierte en salto")
	Input.action_release(&"jump")
	check(not forest.stage.completed, "Nuevo intento al entrar")
	forest._toggle_pause()
	check(paused, "Pausa disponible después de entrar")
	check(not forest._reward_toast.visible, "Los avisos de recompensa no tapan los botones de navegación en pausa")
	forest._return_to_map()
	await frames()
	entrance = current_scene
	check(not paused and entrance.page == &"map", "Volver desde pausa abre el mapa y libera la pausa")
	check(entrance.settings.menu_reduced_motion, "La vuelta al mapa conserva accesibilidad")
	check(root.find_children("BosqueEsmeralda", "", true, false).is_empty(), "La salida libera el nivel anterior")
	await tap(entrance.back_button)
	check(entrance.page == &"intro", "Inicio vuelve a la presentación")
	entrance.queue_free()
	await frames()
	await preload("res://tools/tests/audio_cleanup.gd").flush(self)
	print("ENTRADA: %d comprobaciones, %d fallos" % [checks, failures])
	quit(1 if failures else 0)


