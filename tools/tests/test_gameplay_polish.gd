extends SceneTree
## Regresiones del HUD y seguimiento vertical, sin depender de la velocidad de renderizado.

var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func step(count: int) -> void:
	for frame in count:
		await physics_frame
		await process_frame


func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
	print("%s %s" % ["OK" if ok else "FALLO", message])


func _run() -> void:
	var main: Node2D = load("res://game/boot/main.tscn").instantiate()
	root.add_child(main)
	await step(5)
	var hero: DiegoPlayer = main.player
	hero.set_physics_process(false)
	for enemy in main.stage.enemies:
		enemy.set_physics_process(false)
	hero.respawn(Vector2(6000, 240))
	main._process(1.0 / 60.0)
	var previous_y: float = hero.position.y
	var previous_camera_y: float = main._camera.position.y
	for height in [255.0, 320.0, 480.0, 700.0, 900.0]:
		hero.position.y = height
		hero.velocity.y = 900.0
		main._process(1.0 / 60.0)
		check(absf((main._camera.position.y - previous_camera_y) - (height - previous_y)) < 0.1, "la cámara acompaña cada desplazamiento de caída sin retraso")
		check(absf(hero.position.y - main._camera.position.y - 240.0) < 0.1, "Diego conserva su encuadre durante la caída")
		previous_y = height
		previous_camera_y = main._camera.position.y
	main._toggle_pause()
	hero.position.y += 20
	main._process(1.0 / 60.0)
	check(main._camera.position.y == previous_camera_y, "la pausa congela la cámara vertical")
	main._resume()
	hero.respawn(Vector2(6000, 600))
	main._update_health(2)
	main._update_counts(12, 2)
	main.stage.level_keys[0]._on_body_entered(hero)
	check(main._health.text == "2 / 3" and main._health_counter.icon.texture != null, "energía con corazón y contador actualizado")
	check(main._key_counter.text == "1 / 3" and main._keys_card.icon.texture != null, "llave de ramas y cantidad actualizada")
	check(main._leaves_counter.value_label.text.begins_with("12 /") and main._crystals_counter.value_label.text == "2 / 3", "hojas y cristales tienen contadores independientes")
	check(main._keys_card.accessibility_description.contains("Llave 1 recogida") and main._keys_card.accessibility_description.contains("Llave 2 pendiente"), "el detalle accesible identifica las llaves sin depender del color")
	for card in [main._health_counter, main._keys_card, main._leaves_counter, main._crystals_counter]:
		check(card.mouse_filter == Control.MOUSE_FILTER_IGNORE and card.icon.mouse_filter == Control.MOUSE_FILTER_IGNORE and card.value_label.mouse_filter == Control.MOUSE_FILTER_IGNORE, "el contador deja pasar los gestos")
	for viewport_size in [Vector2i(1280, 720), Vector2i(1280, 960), Vector2i(1600, 720), Vector2i(1000, 720)]:
		root.size = viewport_size
		root.content_scale_size = viewport_size
		await step(3)
		main._layout_hud()
		await step(3)
		var panel: Rect2 = main._top_panel.get_global_rect()
		check(panel.end.x <= main.get_viewport_rect().size.x + 0.1 and panel.position.x >= 0, "HUD dentro de pantalla %s" % viewport_size)
		check(panel.size.y <= 90, "HUD compacto en %s" % viewport_size)
		var previous_end: float = panel.position.x
		for card in [main._health_counter, main._keys_card, main._leaves_counter, main._crystals_counter]:
			var rect: Rect2 = card.get_global_rect()
			check(rect.position.x >= previous_end and rect.end.x <= panel.end.x and rect.end.y <= panel.end.y, "contador legible, sin solapamiento ni recorte en %s" % viewport_size)
			previous_end = rect.end.x
	main.queue_free()
	paused = false
	await step(3)
	await _test_descents()
	print("RESULTADO PULIDO: %d comprobaciones, %d fallos" % [checks, failures])
	quit(0 if failures == 0 else 1)


func _test_descents() -> void:
	var arena := Node2D.new()
	root.add_child(arena)
	var floor := ForestPlatform.new()
	floor.position = Vector2(-100, 600)
	floor.dimensions = Vector2(1200, 64)
	floor.is_ground = true
	arena.add_child(floor)
	var ledge := ForestPlatform.new()
	ledge.position = Vector2(350, 400)
	ledge.dimensions = Vector2(300, 64)
	arena.add_child(ledge)
	var hero: DiegoPlayer = load("res://game/features/player/diego.tscn").instantiate()
	arena.add_child(hero)
	hero.set_physics_process(false)
	for kind in ["terron", "moflete"]:
		var enemy := ForestEnemy.new()
		enemy.kind = kind
		enemy.position = Vector2(500, 400)
		enemy.patrol = Vector2(420, 580)
		enemy.movement_bounds = Vector2(410, 590)
		enemy.pursuit_bounds = Vector2(-40, 1040)
		enemy.platform_guard = true
		enemy.player = hero
		arena.add_child(enemy)
		for direction in [-1.0, 1.0]:
			enemy.reset_awareness()
			var target_x: float = 500.0 + direction * 350.0
			hero.respawn(Vector2(target_x, 400))
			hero.invulnerability = 99
			await step(35)
			check(enemy.behaviour == ForestEnemy.Behaviour.CHASE, "%s avisa y persigue por el lado %s" % [kind, direction])
			hero.position.y = 600
			await step(240)
			print("DESCENSO ", kind, " lado=", direction, " posición=", enemy.position, " estado=", enemy.behaviour)
			check(absf(enemy.position.y - 600.0) < 2 and enemy.is_on_floor(), "%s abandona la estructura y aterriza por el lado %s" % [kind, direction])
			check(absf(enemy.position.x - target_x) < 35 and enemy.behaviour == ForestEnemy.Behaviour.CHASE, "%s sigue persiguiendo tras bajar" % kind)
			hero.dead = true
			await step(100)
			check(absf(enemy.position.y - 600.0) < 2, "%s sigue en el suelo al perder al jugador" % kind)
			hero.dead = false
			enemy.reset_awareness()
			check(enemy.position == Vector2(500, 400), "el farol restablece a %s" % kind)
		enemy.queue_free()
		await step(2)
	floor.queue_free()
	await step(2)
	var cautious := ForestEnemy.new()
	cautious.position = Vector2(500, 400)
	cautious.patrol = Vector2(420, 580)
	cautious.movement_bounds = Vector2(410, 590)
	cautious.player = hero
	arena.add_child(cautious)
	hero.respawn(Vector2(850, 400))
	await step(240)
	check(absf(cautious.position.y - 400.0) < 2 and cautious.is_on_floor(), "perseguir no hace caer al enemigo en un vacío sin apoyo")
	arena.queue_free()
	await step(2)
