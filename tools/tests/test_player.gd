extends SceneTree
## Pruebas de comportamiento ejecutadas con la física y las escenas de Godot.

const HERO: PackedScene = preload("res://game/features/player/diego.tscn")
const MAIN: PackedScene = preload("res://game/boot/main.tscn")
const TARGET_SCRIPT = preload("res://game/features/player/practice_target.gd")
var _world: Node2D
var _player: DiegoPlayer
var _failures: int = 0
var _checks: int = 0


func _initialize() -> void:
	root.size = Vector2i(1280, 720)
	# El servidor headless puede ignorar el tamaño físico de ventana.
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	root.content_scale_size = Vector2i(1280, 720)
	_run.call_deferred()


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("FAIL: " + message)
	else:
		print("PASS: " + message)


func _step(frames: int) -> void:
	for _frame in frames:
		await physics_frame
		await process_frame


func _reset(at: Vector2 = Vector2(0, 400)) -> void:
	_player.respawn(at)
	_player.controls.automatic_run = false
	_player.controls.full_jump = false
	await _step(5 if at.y == 400 else 1)


func _jump_height(hold_frames: int) -> float:
	await _reset()
	var highest: float = _player.position.y
	_player.controls.set_virtual_action(&"jump", true)
	for frame in 100:
		if frame == hold_frames:
			_player.controls.set_virtual_action(&"jump", false)
		await _step(1)
		highest = minf(highest, _player.position.y)
		if frame > 5 and _player.is_on_floor():
			break
	_player.controls.clear_virtual()
	return 400.0 - highest


func _run() -> void:
	_world = Node2D.new()
	root.add_child(_world)
	var ground := StaticBody2D.new()
	ground.collision_layer = 1
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(600, 32)
	shape.shape = box
	shape.position = Vector2(0, 416)
	ground.add_child(shape)
	_world.add_child(ground)
	_player = HERO.instantiate()
	_world.add_child(_player)
	await _reset()
	_check(_player.is_on_floor(), "el cuerpo se apoya en el suelo")
	_player.controls.set_virtual_action(&"move_right", true)
	await _step(20)
	_check(absf(_player.velocity.x-210.0) < 1.0, "aceleración hasta velocidad de caminar")
	_player.controls.set_virtual_action(&"run", true)
	await _step(16)
	_check(_player.velocity.x > 320.0, "carrera diferenciada")
	_player.controls.clear_virtual()
	await _step(15)
	_check(absf(_player.velocity.x) < 1.0, "frenado al soltar")
	var tap_height: float = await _jump_height(2)
	var held_height: float = await _jump_height(60)
	print("Alturas medidas: corto=%.2f, mantenido=%.2f" % [tap_height, held_height])
	_check(held_height > tap_height+35.0, "salto de altura variable")
	_check(held_height >= 125.0 and held_height <= 142.0, "salto completo más alto sin perder control: 125–142 px medidos")
	await _reset()
	_player.controls.full_jump = true
	_player.controls.set_virtual_action(&"jump", true)
	await _step(2)
	_player.controls.set_virtual_action(&"jump", false)
	var high: float = _player.position.y
	for _frame in 55:
		await _step(1)
		high = minf(high, _player.position.y)
	_check(absf(400.0-high-held_height) < 4.0, "salto completo accesible sin mantener")
	await _reset(Vector2(280, 400))
	_player.controls.set_virtual_action(&"move_right", true)
	for _frame in 35:
		await _step(1)
		if not _player.is_on_floor():
			break
	await _step(2)
	_player.controls.set_virtual_action(&"jump", true)
	await _step(1)
	_check(_player.velocity.y < -400.0, "margen de salto al abandonar un borde")
	await _reset(Vector2(0, 345))
	_player.velocity.y = 400.0
	await _step(3)
	_player.controls.set_virtual_action(&"jump", true)
	var buffered_jump: bool = false
	for _frame in 12:
		await _step(1)
		buffered_jump = buffered_jump or _player.velocity.y < -300.0
	_check(buffered_jump, "salto anticipado antes de aterrizar")
	await _reset()
	var stomp := StompTarget.new()
	_world.add_child(stomp)
	stomp.position = Vector2(0, 300)
	_check(not stomp.receive_stomp(_player, Vector2(0, 290), -200), "un ascenso no cuenta como pisotón")
	_check(not stomp.receive_stomp(_player, Vector2(0, 330), 300), "contacto desde abajo no cuenta como pisotón")
	_player.position.x = 200
	_check(not stomp.receive_stomp(_player, Vector2(200, 290), 300), "contacto lateral no cuenta como pisotón")
	stomp.queue_free()
	var target := StaticBody2D.new()
	target.set_script(TARGET_SCRIPT)
	target.position = Vector2(0, 400)
	_world.add_child(target)
	await _reset(Vector2(0, 245))
	_player.velocity.y = 220.0
	var bounce_count: Array[int] = [0]
	_player.bounced.connect(func(): bounce_count[0] += 1)
	for _frame in 60:
		await _step(1)
		if bounce_count[0] > 0:
			break
	_check(bounce_count[0] == 1 and _player.velocity.y < 0, "sensor de pies elimina la diana y rebota una vez")
	target.queue_free()
	await _step(2)
	await _reset()
	var ball := ThrowableObject.new()
	ball.position = Vector2(40, 385)
	_world.add_child(ball)
	await _step(6)
	_player.controls.set_virtual_action(&"grab_throw", true)
	await _step(1)
	_player.controls.set_virtual_action(&"grab_throw", false)
	await _step(25)
	_check(_player.held_object == ball and ball.state == ThrowableObject.State.HELD, "recogida mediante sensor y marcador de animación")
	var throwing_target := StaticBody2D.new()
	throwing_target.set_script(TARGET_SCRIPT)
	throwing_target.kind = &"throw"
	throwing_target.position = Vector2(180, 400)
	_world.add_child(throwing_target)
	var releases: Array[int] = [0]
	_player.object_released.connect(func(): releases[0] += 1)
	_player.controls.set_virtual_action(&"grab_throw", true)
	await _step(1)
	_player.controls.set_virtual_action(&"grab_throw", false)
	await _step(28)
	_check(_player.held_object == null and releases[0] == 1, "un lanzamiento produce una sola suelta")
	_check(ball.state != ThrowableObject.State.HELD and not throwing_target.active, "el objeto físico independiente impacta en la diana")
	ball.queue_free()
	throwing_target.queue_free()
	await _reset()
	_check(_player.take_damage(Vector2(100, 400)), "daño activa reacción y resta energía")
	_check(not _player.take_damage(Vector2(100, 400)), "la protección evita daños duplicados")
	_check(_player.health == 2, "energía coherente tras daño duplicado")
	await _step(80)
	_player.take_damage(Vector2(100, 400))
	await _step(80)
	_player.take_damage(Vector2(100, 400))
	_check(_player.dead and _player.sprite.animation == &"defeated", "derrota con animación dedicada")
	await _reset()
	_check(not _player.dead and _player.health == 3, "reaparición restablece el protagonista")
	await _test_crouch()
	_world.queue_free()
	await _step(2)
	await _test_interface()
	print("RESULTADO: %d comprobaciones, %d fallos" % [_checks, _failures])
	await preload("res://tools/tests/audio_cleanup.gd").flush(self)
	quit(0 if _failures == 0 else 1)


func _test_crouch() -> void:
	await _reset()
	var feet: Vector2 = _player.position
	var standing_height: float = (_player.body_collision.shape as CapsuleShape2D).height
	_player.controls.set_virtual_action(&"crouch", true)
	await _step(3)
	_check(_player.crouching and _player.motion_state == &"crouch", "agacharse activa su estado y animación propios")
	_check(is_equal_approx((_player.body_collision.shape as CapsuleShape2D).height, 58.0), "agacharse reduce la cápsula a 58 píxeles")
	_check(_player.position.distance_to(feet) < 0.2 and _player.is_on_floor(), "agacharse conserva el apoyo y la posición de los pies")
	_check(is_equal_approx(_player.body_collision.position.y, -29.0), "la cápsula baja desde la cabeza sin hundirse en el suelo")
	_player.controls.set_virtual_action(&"move_right", true)
	await _step(15)
	_check(absf(_player.velocity.x) < 0.1, "agachado permanece quieto incluso con carrera automática o dirección")
	_player.controls.set_virtual_action(&"jump", true)
	await _step(2)
	_check(_player.crouching and _player.is_on_floor(), "mantener abajo tiene prioridad sobre un salto simultáneo")
	_player.controls.clear_virtual()
	await _step(4)
	_check(not _player.crouching and _player.motion_state == &"idle", "soltar abajo permite levantarse en espacio libre")
	_check(is_equal_approx((_player.body_collision.shape as CapsuleShape2D).height, standing_height), "levantarse restaura la cápsula original")
	_check(_player.is_on_floor(), "soltar abajo no ejecuta un salto acumulado")
	_player.controls.set_virtual_action(&"crouch", true)
	await _step(2)
	var roof := StaticBody2D.new()
	roof.collision_layer = 1
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(160, 24)
	shape.shape = box
	roof.add_child(shape)
	roof.position = Vector2(0, 318)
	_world.add_child(roof)
	await _step(3)
	_player.controls.clear_virtual()
	_player.controls.set_virtual_action(&"jump", true)
	await _step(3)
	_check(not _player.can_stand() and _player.crouching, "un techo a 70 píxeles impide levantarse al soltar")
	_check(_player.is_on_floor() and _player.position.distance_to(feet) < 0.2, "bajo el techo no salta ni atraviesa el obstáculo")
	_player.controls.clear_virtual()
	roof.queue_free()
	await _step(4)
	_check(not _player.crouching and _player.can_stand(), "se levanta automáticamente cuando vuelve a haber espacio")
	var other: DiegoPlayer = HERO.instantiate()
	other.position = Vector2(2000, 0)
	_world.add_child(other)
	other.set_physics_process(false)
	_player.controls.set_virtual_action(&"crouch", true)
	await _step(2)
	_check(is_equal_approx((other.body_collision.shape as CapsuleShape2D).height, standing_height), "agacharse no modifica las colisiones de otra instancia")
	other.queue_free()
	await _reset(Vector2(0, 250))
	_player.controls.set_virtual_action(&"crouch", true)
	await _step(2)
	_check(not _player.crouching, "no se encoge al pulsar abajo en el aire")
	await _step(40)
	_check(_player.crouching and _player.is_on_floor(), "mantener abajo al caer se aplica al aterrizar")
	_check(_player.take_damage(Vector2(100, 400)) and _player.health == 2, "agacharse mantiene las reglas de daño")
	await _reset()
	_check(not _player.crouching and is_equal_approx((_player.body_collision.shape as CapsuleShape2D).height, standing_height), "reaparecer restablece postura y colisión")
	var ball := ThrowableObject.new()
	ball.position = Vector2(40, 385)
	_world.add_child(ball)
	await _step(6)
	_player.controls.set_virtual_action(&"grab_throw", true)
	await _step(1)
	_player.controls.set_virtual_action(&"grab_throw", false)
	await _step(25)
	var hand_y: float = _player.hand.position.y
	_player.controls.set_virtual_action(&"crouch", true)
	await _step(3)
	_check(_player.crouching and _player.held_object == ball and _player.hand.position.y > hand_y, "el objeto sostenido acompaña la postura baja")
	_player.controls.set_virtual_action(&"grab_throw", true)
	await _step(24)
	_check(_player.held_object == ball, "un toque no lanza desde una postura bloqueada por abajo")
	_player.controls.clear_virtual()
	await _step(4)
	_check(not _player.crouching and is_equal_approx(_player.hand.position.y, hand_y), "levantarse restaura el agarre sin lanzar por accidente")
	ball.queue_free()
	await _reset()
	_player.controls.set_virtual_action(&"crouch", true)
	await _step(2)
	var goal := Area2D.new()
	goal.collision_layer = 64
	goal.collision_mask = 2
	var goal_shape := CollisionShape2D.new()
	var goal_box := RectangleShape2D.new()
	goal_box.size = Vector2(100, 100)
	goal_shape.shape = goal_box
	goal.add_child(goal_shape)
	goal.position = Vector2(0, 350)
	goal.body_entered.connect(func(body: Node2D):
		if body == _player:
			_player.celebrate()
	)
	_world.add_child(goal)
	await _step(4)
	_check(_player.celebrating and not _player.crouching, "llegar agachado a una meta restaura la postura fuera del callback físico")
	goal.queue_free()
	await _reset()


func _touch(index: int, point: Vector2, pressed: bool, canceled: bool = false) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = point
	event.pressed = pressed
	event.canceled = canceled
	root.push_input(event, true)


func _drag(index: int, point: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = point
	root.push_input(event, true)


func _test_interface() -> void:
	var main: Node2D = MAIN.instantiate()
	root.add_child(main)
	await _step(5)
	main.settings.show_touch = true
	main.settings.left_handed = false
	main.settings.gesture_scale = 1.0
	main.settings.automatic_run = false
	main.settings.show_gesture_hints = true
	main._apply_settings()
	main.touch.refresh()
	var view: Vector2 = main.touch.size
	_check(is_equal_approx(view.x/view.y, 16.0/9.0), "el lienzo de prueba inicial tiene proporción móvil 16:9")
	var left := Vector2(view.x*0.2, view.y*0.3)
	var right := Vector2(view.x*0.75, view.y*0.65)
	_touch(6, right, true)
	_drag(6, right+Vector2(0, 65))
	_check(main.player.controls.held(&"crouch") and not main.player.controls.held(&"jump"), "deslizar abajo mantiene agacharse sin saltar")
	_touch(6, right+Vector2(0, 65), false)
	_check(not main.player.controls.held(&"crouch") and not main.player.controls.consume(&"grab_throw"), "soltar abajo libera agacharse sin coger ni lanzar")
	_touch(6, right, true)
	_drag(6, right+Vector2(0, 65))
	_touch(7, right+Vector2(80, -90), true)
	_drag(7, right+Vector2(80, -25))
	_touch(6, right+Vector2(0, 65), false, true)
	_check(main.player.controls.held(&"crouch"), "cancelar un dedo conserva el otro gesto de agacharse")
	_touch(7, right+Vector2(80, -25), false, true)
	_check(not main.player.controls.held(&"crouch"), "cancelar el último gesto libera agacharse")
	_touch(6, right, true)
	_drag(6, right+Vector2(0, 65))
	_drag(6, left)
	_check(main.player.controls.held(&"crouch") and not main.player.controls.held(&"jump"), "cruzar la pantalla conserva la función de agacharse")
	_touch(6, Vector2(-10, -10), false)
	_check(not main.player.controls.held(&"crouch") and not main.player.controls.consume(&"grab_throw"), "soltar el gesto abajo fuera de pantalla libera sin actuar")
	_touch(6, right, true)
	_drag(6, right+Vector2(0, 65))
	main._toggle_pause()
	_check(paused and not main.player.controls.held(&"crouch"), "pausar libera el gesto de agacharse")
	Input.action_press(&"crouch")
	main._toggle_pause()
	_check(not main.player.controls.held(&"crouch"), "reanudar bloquea abajo si la tecla sigue pulsada")
	Input.action_release(&"crouch")
	main.player.controls.held(&"crouch")
	Input.action_press(&"crouch")
	_check(main.player.controls.held(&"crouch"), "una nueva pulsación física de abajo vuelve a funcionar")
	Input.action_release(&"crouch")
	_touch(6, right, true)
	_drag(6, right+Vector2(0, 65))
	main.touch.notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	_check(not main.player.controls.held(&"crouch"), "perder el foco libera agacharse")
	_touch(0, left, true)
	_check(is_zero_approx(main.player.controls.horizontal()), "apoyar el dedo en un punto libre no inicia el movimiento")
	_drag(0, left+Vector2(3, 0))
	_check(is_zero_approx(main.player.controls.horizontal()), "la zona muerta evita moverse por pequeños temblores")
	_drag(0, left+Vector2(35, 0))
	_check(main.player.controls.horizontal() > 0.2 and main.player.controls.horizontal() < 0.8, "arrastre corto produce movimiento analógico")
	_drag(0, left+Vector2(180, 0))
	await _step(14)
	_check(main.player.velocity.x > 300 and main.player.controls.held(&"run"), "arrastre largo corre sin botón de carrera")
	var across := Vector2(view.x*0.7, left.y)
	_drag(0, across)
	_check(main.player.controls.horizontal() > 0.9 and not main.player.controls.held(&"jump"), "cruzar el centro conserva el control de movimiento")
	_drag(0, across-Vector2(200, 0))
	_check(main.player.controls.horizontal() < -0.9, "el origen flotante permite invertir sin volver al punto inicial")
	_touch(0, Vector2(-10, -10), false)
	_check(is_zero_approx(main.player.controls.horizontal()) and not main.player.controls.held(&"run"), "soltar fuera de la pantalla detiene movimiento y carrera")
	# Mover, mantener salto y dar un tercer toque no se bloquean entre sí.
	_touch(0, left, true)
	_drag(0, left+Vector2(90, 0))
	_touch(1, right, true)
	_drag(1, right-Vector2(0, 65))
	_touch(2, right+Vector2(100, -100), true)
	_touch(2, right+Vector2(102, -100), false)
	_check(main.player.controls.horizontal() > 0.9 and main.player.controls.held(&"jump") and main.player.controls.consume(&"grab_throw"), "mover, saltar y actuar con tres contactos simultáneos")
	_check(not main.player.controls.consume(&"grab_throw"), "un toque genera una sola orden de coger o lanzar")
	await _step(2)
	_check(main.player.velocity.y < -200, "el deslizamiento hacia arriba salta con la física real")
	_touch(1, right-Vector2(0, 65), false)
	_check(not main.player.controls.held(&"jump") and not main.player.controls.consume(&"grab_throw"), "soltar un salto no se confunde con un toque de acción")
	_touch(0, left+Vector2(90, 0), false)
	# La mitad de acción funciona arriba y abajo, sin objetivos fijos.
	for point in [Vector2(view.x*0.56, 150), Vector2(view.x-35, view.y-40)]:
		_touch(3, point, true)
		_touch(3, point, false)
		_check(main.player.controls.consume(&"grab_throw"), "toque de acción desde un punto libre de su mitad: %s" % point)
	_touch(3, right, true)
	_drag(3, right+Vector2(90, 35))
	_drag(3, right)
	_touch(3, right, false)
	_check(not main.player.controls.consume(&"grab_throw"), "un arrastre que vuelve al origen no lanza por accidente")
	_touch(3, right, true)
	await _step(30)
	_touch(3, right, false)
	_check(not main.player.controls.consume(&"grab_throw"), "una pulsación larga de descanso no actúa al soltar")
	_touch(3, right, true)
	_touch(3, right, false, true)
	_check(not main.player.controls.consume(&"grab_throw"), "cancelar un contacto no recoge ni lanza")
	_touch(3, right, true)
	_drag(3, right-Vector2(0, 65))
	_touch(4, right+Vector2(80, 0), true)
	_drag(4, right+Vector2(80, -65))
	_touch(3, right-Vector2(0, 65), false, true)
	_check(main.player.controls.held(&"jump"), "cancelar un dedo conserva otro contacto de salto activo")
	_touch(4, right+Vector2(80, -65), false, true)
	_check(not main.player.controls.held(&"jump"), "cancelar el último salto libera la acción")
	_touch(3, right, true)
	_touch(3, right-Vector2(0, 70), false)
	_check(main.player.controls.consume(&"jump") and not main.player.controls.consume(&"grab_throw"), "un deslizamiento rápido sin evento intermedio también salta")
	# Godot puede emular ratón desde touch; ese duplicado no es otro gesto.
	var mouse := InputEventMouseButton.new()
	mouse.device = InputEvent.DEVICE_ID_EMULATION
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.position = right
	mouse.pressed = true
	root.push_input(mouse, true)
	mouse.pressed = false
	root.push_input(mouse, true)
	_check(not main.player.controls.consume(&"grab_throw"), "el ratón emulado desde touch no duplica las acciones")
	_touch(0, left, true)
	_drag(0, left+Vector2(100, 0))
	main._toggle_pause()
	_check(paused and not main.player.controls.enabled and main.touch._pointers.is_empty(), "pausa detiene la física y libera los gestos")
	Input.action_press(&"jump")
	main._toggle_pause()
	_drag(0, left+Vector2(150, 0))
	_check(not paused and not main.player.controls.held(&"jump") and is_zero_approx(main.player.controls.horizontal()), "reanudar ignora contactos anteriores y teclas aún pulsadas")
	Input.action_release(&"jump")
	# Pausa es una interfaz real: tocarla no inicia ningún gesto del juego.
	var pause_control: Control = main.touch.excluded_controls[0]
	var pause_point: Vector2 = pause_control.get_global_rect().get_center()
	_touch(5, pause_point, true)
	_touch(5, pause_point, false)
	_check(main.touch._pointers.is_empty() and not main.player.controls.consume(&"grab_throw"), "tocar Pausa queda fuera de los gestos de juego")
	if not paused:
		for down in [true, false]:
			var click := InputEventMouseButton.new()
			click.button_index = MOUSE_BUTTON_LEFT
			click.position = pause_point
			click.pressed = down
			root.push_input(click, true)
	_check(paused, "la interfaz recibe el clic de Pausa antes que los gestos")
	main._toggle_pause()
	# Perder el foco limpia tanto el eje como un salto mantenido.
	_touch(0, left, true)
	_drag(0, left+Vector2(90, 0))
	_touch(1, right, true)
	_drag(1, right-Vector2(0, 65))
	main.touch.notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	_check(is_zero_approx(main.player.controls.horizontal()) and not main.player.controls.held(&"jump"), "perder el foco libera movimiento y salto")
	main.settings.left_handed = true
	main.touch.refresh()
	_touch(0, right, true)
	_drag(0, right-Vector2(100, 0))
	_touch(1, left, true)
	_drag(1, left-Vector2(0, 60))
	_check(main.player.controls.horizontal() < -0.9 and main.player.controls.held(&"jump"), "intercambiar las zonas cambia realmente los gestos")
	main.touch.release_all()
	main.settings.left_handed = false
	main.settings.gesture_scale = 1.4
	main.touch.refresh()
	_touch(0, left, true)
	_drag(0, left+Vector2(35, 0))
	_check(main.player.controls.horizontal() > 0 and main.player.controls.horizontal() < 0.4, "aumentar el recorrido permite ajustar la sensibilidad")
	main.touch.release_all()
	root.size = Vector2i(1024, 768)
	root.content_scale_size = Vector2i(1280, 960)
	await _step(4)
	view = main.touch.size
	_check(is_equal_approx(view.x/view.y, 4.0/3.0), "el lienzo de prueba se adapta realmente a tablet 4:3")
	_touch(0, Vector2(100, 160), true)
	_drag(0, Vector2(260, 160))
	_touch(1, Vector2(view.x-45, view.y-45), true)
	_drag(1, Vector2(view.x-45, view.y-110))
	_check(main.player.controls.horizontal() > 0.9 and main.player.controls.held(&"jump"), "gestos simultáneos en las esquinas de una tablet 4:3")
	main.touch.release_all()
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1280, 720)
	await _step(4)
	main.touch._guide_time = 0.02
	await _step(3)
	_check(not main.touch._move_hint.visible and not main.touch._action_hint.visible, "la guía desaparece y deja libre la pantalla")
	var joy_count: int = 0
	for event in InputMap.action_get_events(&"jump"):
		if event is InputEventJoypadButton:
			joy_count += 1
	_check(main.settings.rebind(&"jump", KEY_F2), "reasignación de teclado")
	var joy_after: int = 0
	for event in InputMap.action_get_events(&"jump"):
		if event is InputEventJoypadButton:
			joy_after += 1
	_check(joy_count == joy_after and joy_after > 0, "reasignar teclado conserva el mando")
	_check(main.settings.rebind(&"crouch", KEY_F3), "agacharse permite reasignar su tecla")
	var crouch_joy_events: int = 0
	for event in InputMap.action_get_events(&"crouch"):
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			crouch_joy_events += 1
	_check(crouch_joy_events == 2, "reasignar agacharse conserva cruceta y palanca del mando")
	main.settings.reset_keys()
	main.queue_free()
	await _step(2)
	await _test_settings_migration()


func _test_settings_migration() -> void:
	var existed: bool = FileAccess.file_exists(ControlSettings.PATH)
	var original: PackedByteArray = FileAccess.get_file_as_bytes(ControlSettings.PATH) if existed else PackedByteArray()
	var legacy := ConfigFile.new()
	legacy.set_value("controls", "button_scale", 1.3)
	legacy.set_value("controls", "left_handed", true)
	legacy.set_value("controls", "full_jump", true)
	legacy.save(ControlSettings.PATH)
	var settings := ControlSettings.new()
	root.add_child(settings)
	_check(is_equal_approx(settings.gesture_scale, 1.3) and settings.left_handed and settings.full_jump, "los ajustes de la versión con botones migran sin perder preferencias")
	settings.gesture_scale = 1.1
	settings.show_gesture_hints = false
	settings.save()
	var saved := ConfigFile.new()
	saved.load(ControlSettings.PATH)
	_check(is_equal_approx(float(saved.get_value("controls", "gesture_scale")), 1.1) and not saved.get_value("controls", "show_gesture_hints"), "recorrido y guía de gestos se guardan de forma persistente")
	settings.queue_free()
	if existed:
		var file := FileAccess.open(ControlSettings.PATH, FileAccess.WRITE)
		file.store_buffer(original)
		file.close()
	else:
		DirAccess.remove_absolute(ControlSettings.PATH)
	await _step(1)


