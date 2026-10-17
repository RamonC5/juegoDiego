extends SceneTree
## Transporte real, recuperación, pausa y tercera llave de los troncos viajeros.

const ROUTE = preload("res://tools/tests/moving_platform_route.gd")
const STORAGE: String = "user://moving-platform-test-progress.json"
var main: Node2D
var _checks: int = 0
var _failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _step(count: int) -> void:
	await ROUTE.step(self, count)


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
	print("%s %s" % ["OK" if condition else "FALLO", description])


func _new_level() -> void:
	if is_instance_valid(main):
		main.queue_free()
		paused = false
		await _step(3)
	main = load("res://game/boot/main.tscn").instantiate()
	root.add_child(main)
	main.progress = LevelProgress.new(STORAGE)
	main.settings.show_touch = true
	main._apply_settings()
	main.touch.refresh()
	await _step(6)


func _swipe_jump(left_handed: bool) -> void:
	main.settings.left_handed = left_handed
	main.touch.refresh()
	var point := Vector2(root.size.x * (0.25 if left_handed else 0.75), root.size.y * 0.72)
	var press := InputEventScreenTouch.new()
	press.index = 81
	press.position = point
	press.pressed = true
	main.touch._unhandled_input(press)
	var drag := InputEventScreenDrag.new()
	drag.index = 81
	drag.position = point - Vector2(0, 90)
	drag.relative = Vector2(0, -90)
	main.touch._input(drag)
	await _step(3)
	press = press.duplicate()
	press.position = drag.position
	press.pressed = false
	main.touch._input(press)


func _run() -> void:
	root.size = Vector2i(1280, 720)
	DirAccess.remove_absolute(STORAGE)
	await _new_level()
	var hero: DiegoPlayer = main.player
	var stage: ForestStage = main.stage
	var practice: ForestMovingPlatform = stage.moving_platforms[0]
	var lift: ForestMovingPlatform = stage.moving_platforms[1]
	_check(stage.moving_platforms.size() == 2 and practice.definition.platform_id != lift.definition.platform_id, "dos estaciones de una única mecánica nueva")
	_check(stage.level_keys.size() == 3 and not stage.level_keys[2].taken, "se conservan tres llaves distintas")
	_check(practice.support.one_way_collision and lift.support.one_way_collision, "las superficies permiten atravesarlas desde abajo")
	# Preparación aislada sobre el tronco; el desplazamiento posterior es enteramente físico.
	practice.reset_cycle()
	hero.respawn(practice.definition.start_position - Vector2(0, 28))
	await _step(22)
	_check(practice.carries(hero), "aterrizar conecta al pasajero con el tronco horizontal")
	var offset: float = hero.position.x - practice.position.x
	await _step(150)
	_check(hero.position.x > 5700.0 and practice.carries(hero), "el tronco transporta a Diego sin mantener arrastre")
	_check(absf(hero.position.x - practice.position.x - offset) < 4.0, "el pasajero conserva su posición relativa al viajar")
	var clock: float = practice.elapsed
	var position_before: Vector2 = hero.position
	var seconds: float = stage.seconds
	main._toggle_pause()
	await _step(65)
	_check(is_equal_approx(clock, practice.elapsed) and hero.position.is_equal_approx(position_before), "pausar congela plataforma y pasajero")
	_check(is_equal_approx(seconds, stage.seconds), "pausar también congela el tiempo del nivel")
	main._resume()
	await _step(50)
	_check(practice.elapsed > clock and practice.carries(hero), "reanudar conserva el transporte")
	# La caída permite volver andando al puesto, sin pérdida de energía ni muerte.
	hero.controls.automatic_run = false
	hero.controls.set_virtual_axis(-1)
	await _step(100)
	hero.controls.clear_virtual()
	await _step(40)
	_check(not hero.dead and hero.health == 3 and hero.is_on_floor() and hero.position.y > 590.0, "caer del ensayo termina en suelo seguro")
	for left_handed in [false, true]:
		practice.reset_cycle()
		hero.respawn(practice.definition.start_position - Vector2(0, 28))
		await _step(22)
		await _swipe_jump(left_handed)
		_check(hero.velocity.y < -300.0 and not practice.carries(hero), "deslizar arriba permite saltar del tronco con lados %s" % ("intercambiados" if left_handed else "normales"))
	main.settings.left_handed = false
	main.touch.refresh()
	# Ascensor: atravesar desde abajo y comprobar ambos sentidos con pasajero quieto.
	lift.reset_cycle()
	hero.respawn(Vector2(6460, 600))
	hero.controls.full_jump = true
	await _step(5)
	hero.controls.set_virtual_action(&"jump", true)
	await _step(45)
	hero.controls.clear_virtual()
	_check(lift.carries(hero), "un salto desde el suelo embarca atravesando el tronco por debajo")
	await _step(230)
	_check(lift.carries(hero) and hero.position.y < 310.0, "el ascensor eleva al pasajero hasta la repisa")
	await _step(260)
	_check(lift.carries(hero) and hero.position.y > 530.0 and hero.health == 3, "el descenso transporta sin aplastar ni herir")
	# Muerte y retorno al farol: llaves y puentes resueltos permanecen; los troncos vuelven abajo.
	stage.level_keys[0]._on_body_entered(hero)
	stage._on_mechanism_activated(&"puente_diana_ensayo")
	stage._on_checkpoint(hero, 2)
	hero._die()
	await _step(65)
	main._resume()
	await _step(4)
	_check(not hero.dead and hero.position.distance_to(stage.respawn_position) < 4.0, "morir devuelve al farol en suelo firme")
	_check(stage.collected_keys == [0] and stage.bridges[0].state == RootBridge.State.OPEN, "el reintento conserva llave y puente resueltos")
	_check(lift.position.distance_to(lift.definition.start_position) < 2.0 and stage.moving_platforms.size() == 2, "los dos troncos reinician su ciclo sin duplicarse")
	_check(LevelProgress.new(STORAGE).levels.is_empty(), "viajar o recoger una llave no inventa guardado de intento")
	# El salto normal desde abajo no alcanza la llave alta.
	hero.respawn(Vector2(6760, 600))
	await _step(3)
	hero.controls.full_jump = true
	hero.controls.set_virtual_action(&"jump", true)
	await _step(65)
	hero.controls.clear_virtual()
	_check(not stage.level_keys[2].taken, "la tercera llave requiere ganar altura usando el tronco")
	# Acceso completo desde tierra a la llave sin teletransportes durante este recorrido.
	hero.respawn(Vector2(6220, 600))
	await _step(5)
	_check(await ROUTE.reach_third_key(main), "embarcar, subir, saltar y recoger la tercera llave con entradas reales")
	var count: int = stage.collected_keys.size()
	stage.level_keys[2]._on_body_entered(hero)
	_check(stage.collected_keys.size() == count and count == 2 and not stage.exit_door.is_open, "repetir contacto no duplica llaves ni abre con dos")
	# Volver al suelo permite regresar hacia una llave pendiente.
	_check(await ROUTE.walk_to(main, 6540.0), "la repisa permite regresar hacia el tronco y las llaves pendientes")
	await _step(100)
	_check(not hero.dead and hero.health == 3, "el retorno desde la repisa es seguro")
	await _new_level()
	_check(main.stage.collected_keys.is_empty() and not main.stage.exit_door.is_open, "reiniciar repone las tres llaves y cierra la salida")
	_check(main.stage.moving_platforms.size() == 2 and main.stage.moving_platforms[1].elapsed < 0.2, "la rejugada crea dos ciclos nuevos sin instancias extra")
	main.queue_free()
	paused = false
	await _step(3)
	DirAccess.remove_absolute(STORAGE)
	print("RESULTADO TRONCOS: %d comprobaciones, %d fallos" % [_checks, _failures])
	quit(0 if _failures == 0 else 1)
