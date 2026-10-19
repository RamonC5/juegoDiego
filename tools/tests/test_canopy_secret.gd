extends "res://tools/tests/test_forest_route.gd"
## Desde el farol hasta la bajada: todos los desplazamientos usan controles.


func _run() -> void:
	var storage: String = "user://canopy-%d-%d.json" % [OS.get_process_id(), Time.get_ticks_usec()]
	main = load("res://game/boot/forest_level_02.tscn").instantiate()
	main.collection_progress = CollectionProgress.new(storage)
	root.add_child(main)
	stage = main.stage
	hero = main.player
	await step(8)
	var secret: ForestCanopySecret = stage.canopy_secret
	if not check(is_instance_valid(secret), "Ruta secreta construida desde el recurso"):
		_finish()
		return
	hero.health = 2
	# Solo se coloca el inicio de la prueba; entrada, trepa y ruta son físicos.
	hero.respawn(Vector2(19300, 600))
	hero.health = 2
	hero.invulnerability = 0
	check(await walk_to(secret.position.x), "Llegar a la liana pasando por el primer farol")
	check(stage.active_checkpoint_index == 0 and hero.health == 2, "Farol mantiene salud parcial")
	check(secret.totem._nearby and secret.totem.get_child_count() == 0, "Tótem accesible sin barreras ni controles nuevos")
	check(hero.swinging_vines.count(secret.vine) == 1 and secret.vine.length == 800, "Liana larga registrada una sola vez")
	hero.controls.set_virtual_action(&"jump", true)
	for frame in 60:
		await step(1)
		if is_instance_valid(hero.attached_vine):
			break
	hero.controls.clear_virtual()
	if not check(hero.attached_vine == secret.vine, "Salto y agarre automático en la base"):
		_finish()
		return
	await step(30)
	check(is_zero_approx(hero.vine_climb_distance), "Colgarse no inicia trepa automática")
	hero.controls.set_virtual_action(&"climb_up", true)
	await step(100)
	var climb_before_pause: float = hero.vine_climb_distance
	var cycle_before_pause: float = secret.vine.elapsed
	paused = true
	await step(8)
	check(hero.vine_climb_distance == climb_before_pause and secret.vine.elapsed == cycle_before_pause, "Pausa detiene trepa y balanceo")
	paused = false
	await step(220)
	hero.controls.clear_virtual()
	check(hero.vine_climb_distance > 700 and hero.position.y < -120, "ARRIBA permite subir por encima de los árboles")
	check(hero.vine_climb_distance <= secret.vine.length - DiegoPlayer.VINE_TOP_MARGIN, "Trepa respeta el anclaje superior de la liana larga")
	check(hero.health == 2, "Acceso y trepa sin daño con enemigos activos y sin invulnerabilidad")
	# El resto del recorrido aísla geometría, como la suite de la ruta principal.
	for enemy in stage.enemies:
		enemy.set_physics_process(false)
		enemy.collision_layer = 0
		enemy._stomp.collision_layer = 0
		enemy._contact.monitoring = false
	hero.invulnerability = 100000
	hero.collision_mask = 1
	hero.foot_sensor.collision_mask = 0
	var first: Rect2 = ForestCanopySecret.CROWNS[0]
	if not check(await jump_to(secret.position.x + first.position.x + 100, secret.position.y + first.position.y), "Soltar con salto permite aterrizar sobre la primera copa"):
		_finish()
		return
	for index in range(1, ForestCanopySecret.CROWNS.size()):
		var previous: Rect2 = ForestCanopySecret.CROWNS[index - 1]
		var next: Rect2 = ForestCanopySecret.CROWNS[index]
		if not check(await walk_to(secret.position.x + previous.end.x - 25) and await jump_to(secret.position.x + next.position.x + 85, secret.position.y + next.position.y), "Cruzar copa %d con saltos reales" % (index + 1)):
			_finish()
			return
	check(await walk_to(secret.position.x + ForestCanopySecret.REWARD_POSITION.x), "Alcanzar brote por el sendero alto")
	check(secret.reward_taken and hero.maximum_health == 4 and hero.health == 4, "Una vida extra por intento al tocar el brote")
	var count_before: int = main.collection_progress.count("leaf", "world_01_level_02")
	check(count_before >= 12 and stage.collected_keys.is_empty(), "Hojas permanentes opcionales, sin llave en las copas")
	hero.health = 2
	secret._on_reward_body_entered(hero)
	check(hero.health == 2 and hero.maximum_health == 4, "Reentrada no repite premio ni curación")
	var previous: Rect2 = ForestCanopySecret.CROWNS[-1]
	for next in ForestCanopySecret.DESCENT:
		if not check(await walk_to(secret.position.x + previous.end.x - 25) and await jump_to(secret.position.x + next.position.x + 70, secret.position.y + next.position.y), "Descenso por rama a altura %d" % (secret.position.y + next.position.y)):
			_finish()
			return
		previous = next
	check(await walk_to(secret.position.x + ForestCanopySecret.ROUTE_END + 100), "Salir de la última rama hacia el sendero")
	await step(80)
	check(hero.is_on_floor() and absf(hero.position.y - 600) < 4 and not hero.dead, "Regreso físico a suelo seguro antes del portón")
	stage.respawn_player()
	await step(5)
	check(secret.reward_taken and hero.maximum_health == 4 and hero.health == 4, "Reaparición conserva vida del intento")
	check(hero.swinging_vines.count(secret.vine) == 1 and not is_instance_valid(hero.attached_vine), "Reaparición suelta la liana y evita registros duplicados")
	var reopened := CollectionProgress.new(storage)
	check(reopened.count("leaf", "world_01_level_02") >= count_before, "Hojas del dosel guardadas al reabrir")
	var fresh := ForestCanopySecret.new()
	root.add_child(fresh)
	check(not fresh.reward_taken, "Un nuevo intento repone el brote")
	fresh.queue_free()
	_finish()
