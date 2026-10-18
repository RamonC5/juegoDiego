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
		check(entrance.intro.actor.animation == WorldCatalog.WORLDS[index].pose, "Pose real del protagonista")
		check(entrance.intro.actor.position.is_finite(), "Actor con posición válida")
	entrance.intro.set_reduced_motion(true)
	var clock: float = entrance.intro.clock
	entrance.intro._process(2.0)
	check(entrance.intro.clock == clock and not entrance.intro.actor.is_playing(), "Movimiento reducido congela montaje y sprite")
	entrance.settings.menu_reduced_motion = false
	entrance._toggle_motion()
	var persisted := ControlSettings.new()
	root.add_child(persisted)
	check(persisted.menu_reduced_motion, "La preferencia de movimiento se guarda")
	persisted.queue_free()
	await tap(entrance.play_button)
	await frames()
	check(entrance.page == &"map" and entrance.world_map.visible, "Toque Jugar ahora abre el mapa")
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
