extends SceneTree
## Doble salto real, entradas entre pasos físicos y manos ancladas al raster de la liana.

var hero: DiegoPlayer
var world: Node2D
var checks: int = 0
var failures: int = 0
var jumps: int = 0


func _initialize() -> void:
	_run.call_deferred()


func step(count: int = 1) -> void:
	for frame in count:
		await physics_frame
		await process_frame


func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
	print("%s %s" % ["OK" if ok else "FALLO", message])


func reset(at: Vector2 = Vector2(0, 400)) -> void:
	hero.respawn(at)
	hero.controls.full_jump = false
	hero.controls.automatic_run = false
	await step(5 if at.y == 400 else 1)
	jumps = 0


func _run() -> void:
	world = Node2D.new()
	root.add_child(world)
	var ground := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(600, 40)
	shape.shape = box
	shape.position = Vector2(0, 420)
	ground.add_child(shape)
	world.add_child(ground)
	hero = preload("res://game/features/player/diego.tscn").instantiate()
	world.add_child(hero)
	hero.jumped.connect(func(): jumps += 1)
	await reset()
	hero.controls.request_tap_jump()
	await step()
	check(hero.jumps_used == 1 and hero.velocity.y < -640, "un toque da el impulso inicial inmediatamente")
	check(not hero.controls.held(&"jump"), "el toque no depende de mantener el dedo")
	await step(10)
	check(hero.position.y < 310, "soltar el toque conserva la altura completa")
	hero.controls.request_tap_jump()
	await step()
	check(hero.jumps_used == 2 and hero.velocity.y < -550, "segundo toque vuelve a impulsar durante el ascenso")
	check(hero.motion_state == &"double_jump" and hero.sprite.frame == 0, "segundo impulso reinicia una animación reconocible")
	var rising_speed: float = hero.velocity.y
	hero.controls.request_tap_jump()
	await step()
	check(jumps == 2 and hero.velocity.y > rising_speed, "un tercer toque no crea otro salto")
	await step(85)
	check(hero.is_on_floor() and hero.jumps_used == 0, "aterrizar recupera los dos saltos")
	hero.controls.request_tap_jump()
	await step()
	check(jumps == 3 and hero.jumps_used == 1, "se puede volver a saltar al aterrizar")
	await reset()
	hero.controls.request_tap_jump()
	await step(28)
	check(hero.velocity.y > 0, "se alcanza el descenso antes de la corrección tardía")
	hero.controls.request_tap_jump()
	await step()
	check(hero.velocity.y < -550 and hero.jumps_used == 2, "el doble salto también frena una caída")
	await reset()
	hero.controls.request_tap_jump()
	hero.controls.request_tap_jump()
	await step(2)
	check(jumps == 2 and hero.jumps_used == 2, "dos toques entre pasos físicos se ejecutan por separado")
	await step(10)
	check(jumps == 2, "mantener el contacto no produce repetición automática")
	await reset(Vector2(550, 230))
	hero.controls.request_tap_jump()
	await step()
	check(hero.jumps_used == 2 and hero.velocity.y < -550, "caer desde un borde deja una única corrección aérea")
	hero.controls.request_tap_jump()
	await step()
	check(jumps == 1, "la caída no regala un tercer impulso")
	await reset()
	hero.take_damage(Vector2(100, 400))
	hero.controls.request_tap_jump()
	await step(30)
	check(jumps == 0, "un golpe descarta saltos que no se pueden ejecutar")
	hero.controls.request_tap_jump()
	hero.respawn(Vector2(0, 400))
	await step(5)
	check(hero.is_on_floor() and jumps == 0, "reaparecer limpia los toques pendientes")
	await _test_stomp()
	await _test_air_throw()
	await _test_vine()
	await _test_climb_ceiling()
	world.queue_free()
	await step(3)
	print("MOVIMIENTOS: %d comprobaciones, %d fallos" % [checks, failures])
	quit(0 if failures == 0 else 1)


func _test_stomp() -> void:
	var target := StaticBody2D.new()
	target.set_script(preload("res://game/features/player/practice_target.gd"))
	target.position = Vector2(0, 400)
	world.add_child(target)
	hero.respawn(Vector2(0, 245))
	hero.jumps_used = 2
	hero.velocity.y = 220.0
	for frame in 60:
		await step()
		if hero.velocity.y < 0.0:
			break
	check(hero.velocity.y < 0.0 and hero.jumps_used == 1, "un pisotón restaura una corrección aérea después del rebote")
	hero.controls.request_tap_jump()
	await step()
	check(hero.velocity.y < -550 and hero.jumps_used == 2, "se puede corregir el vuelo después de pisar un enemigo")
	var old_jumps: int = jumps
	hero.controls.request_tap_jump()
	await step()
	check(jumps == old_jumps, "el rebote no concede dos correcciones aéreas")
	target.queue_free()
	await step(2)


func _test_air_throw() -> void:
	for direction in [-1.0, 1.0]:
		await reset()
		var ball := ThrowableObject.new()
		world.add_child(ball)
		hero.held_object = ball
		ball.pick_up(hero.hand)
		var releases: Array[int] = [0]
		var connection: Callable = func(): releases[0] += 1
		hero.object_released.connect(connection)
		hero.controls.set_virtual_axis(direction)
		await step(12)
		hero.controls.request_tap_jump()
		hero.controls.set_virtual_action(&"grab_throw", true)
		await step()
		hero.controls.set_virtual_action(&"grab_throw", false)
		check(hero._action == &"throw" and hero.velocity.y < -600 and hero.facing == direction, "salto y lanzamiento simultáneos en dirección %s" % direction)
		await step(5)
		check(hero.velocity.x * direction > 150, "lanzar en vuelo conserva el avance")
		hero.controls.request_tap_jump()
		await step()
		check(hero.jumps_used == 2 and hero.velocity.y < -550 and hero.sprite.animation == &"throw", "el segundo salto durante el lanzamiento conserva el marcador de suelta")
		hero.controls.set_virtual_action(&"grab_throw", true)
		await step()
		hero.controls.set_virtual_action(&"grab_throw", false)
		await step(14)
		check(releases[0] == 1 and hero.held_object == null and ball.state == ThrowableObject.State.THROWN, "el marcador libera un único objeto físico en el aire")
		check(ball.velocity.x * direction > 100, "el objeto viaja en la dirección elegida")
		hero.controls.request_tap_jump()
		await step()
		check(hero.jumps_used == 2, "lanzar no renueva la reserva de saltos")
		await step(8)
		check(hero._action.is_empty() and hero.sprite.animation != &"throw", "al terminar el lanzamiento vuelve a la pose aérea")
		hero.object_released.disconnect(connection)
		ball.queue_free()
		await step()
	# El lanzamiento también se inicia durante el descenso.
	await reset(Vector2(800, 180))
	var falling_ball := ThrowableObject.new()
	world.add_child(falling_ball)
	hero.held_object = falling_ball
	falling_ball.pick_up(hero.hand)
	hero.velocity.y = 120
	hero.controls.set_virtual_action(&"grab_throw", true)
	await step()
	hero.controls.set_virtual_action(&"grab_throw", false)
	await step(14)
	check(hero.held_object == null and falling_ball.state == ThrowableObject.State.THROWN and not hero.is_on_floor(), "se puede lanzar durante la caída")
	falling_ball.queue_free()
	await step()


func _test_vine() -> void:
	var vine := ForestSwingingVine.new()
	vine.position = Vector2(1000, -300)
	world.add_child(vine)
	await step(2)
	hero.respawn(vine.grip_global_position() - DiegoPlayer.VINE_HAND_OFFSET + Vector2(35, 0))
	hero.swinging_vines = [vine]
	await step()
	check(hero.attached_vine == vine and hero.motion_state == &"vine_hang", "la liana usa una pose propia con brazos elevados")
	check(hero.vine_hand_global_position().distance_to(vine.grip_global_position()) < 0.1, "las manos tocan el nudo desde el primer fotograma del agarre")
	var maximum_error: float = 0.0
	for frame in 480:
		hero.controls.set_virtual_axis(-1.0 if frame % 120 < 60 else 1.0)
		await step()
		maximum_error = maxf(maximum_error, hero.vine_hand_global_position().distance_to(vine.grip_global_position()))
	check(maximum_error < 0.1, "dos ciclos y cambios de orientación conservan las manos ancladas")
	check(hero.jumps_used == 0, "agarrarse renueva la reserva de salto")
	await _test_climb(vine)
	paused = true
	var previous_hand: Vector2 = hero.vine_hand_global_position()
	var previous_grip: Vector2 = vine.grip_global_position()
	await step(8)
	check(hero.vine_hand_global_position() == previous_hand and vine.grip_global_position() == previous_grip, "pausa congela cuerpo y agarre juntos")
	paused = false
	hero.controls.set_virtual_axis(1.0)
	hero.controls.request_tap_jump()
	await step()
	check(hero.attached_vine == null and hero.jumps_used == 1 and hero.velocity.y < -300, "un toque suelta la cuerda con impulso y un salto aéreo disponible")
	check(hero.facing_node.position == Vector2.ZERO and hero.facing_node.rotation == 0.0 and hero.sprite.animation != &"vine_hang", "soltarse restaura el pivote y la pose aérea")
	hero.controls.request_tap_jump()
	await step()
	check(hero.jumps_used == 2 and hero.velocity.y < -550, "se puede hacer doble salto después de soltar la liana")
	hero.controls.request_tap_jump()
	var old_jumps: int = jumps
	await step()
	check(jumps == old_jumps, "la suelta y el salto aéreo agotan el límite de dos")
	hero.respawn(vine.grip_global_position() - DiegoPlayer.VINE_HAND_OFFSET)
	hero._try_grab_swinging_vine()
	hero.controls.request_tap_jump()
	await step(15)
	check(hero.attached_vine == null, "un toque durante el ajuste inicial se conserva hasta soltar")
	hero.respawn(vine.grip_global_position() - DiegoPlayer.VINE_HAND_OFFSET)
	hero._try_grab_swinging_vine()
	hero.take_damage(hero.position + Vector2(100, 0))
	check(hero.attached_vine == null and hero.facing_node.position == Vector2.ZERO and hero.motion_state == &"hurt", "recibir daño colgado libera el agarre y recupera la pose de golpe")
	hero.swinging_vines.clear()


func _test_climb(vine: ForestSwingingVine) -> void:
	var initial_radius: float = hero.vine_hand_global_position().distance_to(vine.global_position)
	hero.controls.set_virtual_action(&"climb_up", true)
	await step(30)
	check(hero.vine_climb_distance > 70.0 and hero.vine_hand_global_position().distance_to(vine.global_position) < initial_radius - 70, "mantener arriba trepa por la cuerda mientras oscila")
	check(hero.vine_hand_global_position().distance_to(vine.grip_global_position(hero.vine_climb_distance)) < 0.1, "las manos siguen el agarre a la nueva altura")
	hero.controls.set_virtual_action(&"climb_up", false)

	var stopped: float = hero.vine_climb_distance
	await step(20)
	check(is_equal_approx(hero.vine_climb_distance, stopped), "soltar arriba conserva la altura sin trepa automática")
	hero.controls.set_virtual_action(&"climb_up", true)
	paused = true
	await step(8)
	check(is_equal_approx(hero.vine_climb_distance, stopped), "la pausa detiene la trepa")
	paused = false
	await step(150)
	check(is_equal_approx(hero.vine_climb_distance, ForestSwingingVine.LENGTH - DiegoPlayer.VINE_TOP_MARGIN), "el extremo superior limita la trepa sin sobrepasar la liana")
	check(hero.attached_vine == vine and hero.vine_hand_global_position().distance_to(vine.grip_global_position(hero.vine_climb_distance)) < 0.1, "llegar arriba conserva el agarre y el control")
	hero.controls.set_virtual_action(&"climb_up", false)



func _test_climb_ceiling() -> void:
	var vine := ForestSwingingVine.new()
	vine.position = Vector2(1600, 0)
	world.add_child(vine)
	vine.set_physics_process(false)
	var roof := StaticBody2D.new()
	roof.position = Vector2(1600, 200)
	var collision := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(400, 30)
	collision.shape = box
	roof.add_child(collision)
	world.add_child(roof)
	hero.respawn(vine.grip_global_position() - DiegoPlayer.VINE_HAND_OFFSET)
	hero.swinging_vines = [vine]
	hero._try_grab_swinging_vine()
	hero.controls.set_virtual_action(&"climb_up", true)
	await step(120)
	check(hero.attached_vine == vine and hero.vine_climb_distance > 100 and hero.position.y >= 313, "un techo sólido detiene la trepa antes de atravesarlo")
	collision.one_way_collision = true
	await step(120)
	check(is_equal_approx(hero.vine_climb_distance, ForestSwingingVine.LENGTH - DiegoPlayer.VINE_TOP_MARGIN), "trepar atraviesa desde abajo una plataforma unilateral")
	hero.take_damage(hero.position + Vector2(100, 0))
	check(hero.attached_vine == null and is_zero_approx(hero.vine_climb_distance), "el daño limpia la altura de trepa")
	hero.respawn(vine.grip_global_position() - DiegoPlayer.VINE_HAND_OFFSET)
	check(not hero.controls.held(&"climb_up") and is_zero_approx(hero.vine_climb_distance), "reaparecer limpia la entrada y la altura de trepa")
	hero.swinging_vines.clear()
	roof.queue_free()
	vine.queue_free()
	await step(2)
