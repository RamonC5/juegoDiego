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
	_world.queue_free()
	await _step(2)
	await _test_interface()
	print("RESULTADO: %d comprobaciones, %d fallos" % [_checks, _failures])
	quit(0 if _failures == 0 else 1)


func _test_interface() -> void:
	var main: Node2D = MAIN.instantiate()
	root.add_child(main)
	await _step(5)
	main.settings.show_touch = true
	main.touch.refresh()
	for index in 3:
		var action: StringName = [&"move_right", &"jump", &"grab_throw"][index]
		var event := InputEventScreenTouch.new()
		event.index = index
		event.position = main.touch._centres[action]
		event.pressed = true
		root.push_input(event, true)
	await process_frame
	_check(main.player.controls.held(&"move_right") and main.player.controls.held(&"jump") and main.player.controls.held(&"grab_throw"), "tres contactos táctiles simultáneos")
	var drag := InputEventScreenDrag.new()
	drag.index = 0
	drag.position = Vector2(600, 300)
	root.push_input(drag, true)
	_check(not main.player.controls.held(&"move_right"), "arrastrar fuera del botón libera la dirección")
	main._toggle_pause()
	_check(paused and not main.player.controls.enabled, "pausa detiene la física y bloquea órdenes")
	Input.action_press(&"jump")
	main._toggle_pause()
	_check(not paused and not main.player.controls.held(&"jump"), "reanudar libera contactos anteriores")
	Input.action_release(&"jump")
	main.settings.left_handed = true
	main.touch.refresh()
	_check(main.touch._centres[&"jump"].x < main.touch._centres[&"move_right"].x, "disposición táctil intercambiable")
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
	main.settings.reset_keys()
	main.queue_free()
	await _step(2)
