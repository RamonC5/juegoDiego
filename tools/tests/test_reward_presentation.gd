extends SceneTree
## Pulsaciones reales, salida en tamaños compactos y equipo aplicado al jugador.

var failures: int = 0
var checks: int = 0
var storage: String = "user://reward-presentation-%d.json" % OS.get_process_id()

func _initialize() -> void:
	_run.call_deferred()

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func frames(count: int = 5) -> void:
	for i in count:
		await process_frame
		await physics_frame

func click(button: Button, touch: bool = false) -> void:
	var point: Vector2 = button.get_global_rect().get_center()
	if touch:
		var event := InputEventScreenTouch.new()
		event.index = 0
		event.position = point
		event.pressed = true
		root.push_input(event)
		await process_frame
		event = event.duplicate()
		event.pressed = false
		root.push_input(event)
	else:
		var event := InputEventMouseButton.new()
		event.position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = true
		root.push_input(event)
		await process_frame
		event = event.duplicate()
		event.pressed = false
		root.push_input(event)
	await frames()

func cleanup() -> void:
	for suffix in ["", ".tmp", ".bak"]:
		DirAccess.remove_absolute(storage + suffix)

func _run() -> void:
	cleanup()
	var main = preload("res://game/boot/main.tscn").instantiate()
	main.collection_progress = CollectionProgress.new(storage)
	root.add_child(main)
	await frames()
	for enemy in main.stage.enemies:
		enemy.set_physics_process(false)
		enemy.collision_layer = 0
		enemy._contact.monitoring = false
	main.player.set_physics_process(false)
	for dimensions in [Vector2i(1280, 720), Vector2i(960, 540), Vector2i(1024, 768)]:
		root.content_scale_size = Vector2i.ZERO
		root.size = dimensions
		main._open_wardrobe()
		await frames()
		var menu: CollectionMenu = main._collection_menu
		var viewport := Rect2(Vector2.ZERO, dimensions)
		check(viewport.encloses(menu._close_button.get_global_rect()), "Volver está dentro de %s" % dimensions)
		check(viewport.encloses(menu._play_button.get_global_rect()), "Seguir jugando está dentro de %s" % dimensions)
		check(viewport.encloses(menu._body.get_global_rect()), "Catálogo cabe en %s" % dimensions)
		check(menu._actions["forest_explorer"].disabled, "Prenda pendiente bloqueada")
		menu._select("forest_explorer")
		check(main.collection_progress.equipped == "original", "Probar no equipa una prenda pendiente")
		await click(menu._close_button)
		check(paused and not menu.visible and main._menu.visible, "Clic real vuelve a pausa")
		main._open_wardrobe()
		await frames()
		await click(menu._play_button, true)
		check(not paused and main.player.controls.enabled and not menu.visible, "Toque real continúa la partida")
		check(main.touch._pointers.is_empty(), "Continuar libera los dedos del vestuario")
	main._open_wardrobe()
	main.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	check(paused and not main._collection_menu.visible and main._menu.visible, "Atrás Android vuelve a pausa")
	main.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	check(not paused, "Atrás Android permite continuar desde pausa")
	for item in main.stage.collectibles:
		if main.collection_progress.count("leaf") >= 12:
			break
		if not item.crystal:
			item._on_body_entered(main.player)
	main._open_wardrobe()
	await frames()
	await click(main._collection_menu._actions["autumn_scarf"])
	check(main.collection_progress.equipped == "autumn_scarf", "Equipar recibe un clic real")
	check(int(main.player.sprite.material.get_shader_parameter("outfit")) == 1, "Equipo aplicado al sprite de la partida")
	check(main.player.sprite.material.get_shader_parameter("scarf_color") == Color("ff4b48"), "Partida usa la paleta del catálogo")
	check(main.player.sprite.material != main._collection_menu._preview.material, "Jugador y vista previa tienen material independiente")
	check(main._wardrobe_button.text == "2/5", "HUD muestra las equipaciones obtenidas")
	check(CollectionProgress.new(storage).equipped == "autumn_scarf", "La equipación elegida sobrevive al cierre")
	main._close_wardrobe()
	main._resume()
	main.stage.completed = true
	main._open_wardrobe()
	check(main._collection_menu._play_button.disabled, "No reanuda un nivel ya completado")
	main.queue_free()
	paused = false
	await frames()
	cleanup()
	print("PRESENTACIÓN DE RECOMPENSAS: %d comprobaciones, %d fallos" % [checks, failures])
	await preload("res://tools/tests/audio_cleanup.gd").flush(self)
	quit(0 if failures == 0 else 1)
