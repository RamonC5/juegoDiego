extends SceneTree
## Pruebas físicas de recursos, recogida, impactos, rebotes y recuperación.

class HitReceiver extends StaticBody2D:
	var hits: int = 0
	func receive_thrown_hit(object: ThrowableObject) -> void:
		if object.can_cause_thrown_damage():
			hits += 1

var _world: Node2D
var _checks: int = 0
var _failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if condition:
		print("PASS: ", description)
	else:
		_failures += 1
		push_error("FAIL: " + description)


func _step(frames: int) -> void:
	for _frame in frames:
		await physics_frame
		await process_frame


func _new_world() -> void:
	if is_instance_valid(_world):
		_world.queue_free()
		await _step(2)
	_world = Node2D.new()
	root.add_child(_world)
	var floor_body := StaticBody2D.new()
	floor_body.collision_layer = 1
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(4000, 40)
	shape.shape = rectangle
	shape.position = Vector2(1000, 420)
	floor_body.add_child(shape)
	_world.add_child(floor_body)
	await _step(2)


func _object(definition: ThrowableDefinition, at: Vector2 = Vector2(0, 320)) -> ThrowableObject:
	var result := ThrowableObject.new()
	result.definition = definition
	result.position = at
	_world.add_child(result)
	return result


func _launch(object: ThrowableObject, at: Vector2 = Vector2(0, 320), direction: float = 1.0) -> void:
	var hand := Marker2D.new()
	hand.position = at
	_world.add_child(hand)
	object.pick_up(hand)
	object.release(direction, Vector2.ZERO)
	hand.queue_free()


func _receiver() -> HitReceiver:
	var receiver := HitReceiver.new()
	receiver.position = Vector2(180, 400)
	receiver.collision_layer = 4
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(12, 160)
	shape.position.y = -80.0
	shape.shape = rectangle
	receiver.add_child(shape)
	_world.add_child(receiver)
	return receiver


func _wall(x: float = 90.0) -> void:
	var wall := StaticBody2D.new()
	wall.collision_layer = 1
	wall.position = Vector2(x, 250)
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(2, 800)
	shape.shape = rectangle
	wall.add_child(shape)
	_world.add_child(wall)


func _run() -> void:
	_check(ThrowableCatalog.DEFINITIONS.size() == 6, "el catálogo ofrece seis objetos")
	var identifiers: Dictionary = {}
	for definition in ThrowableCatalog.DEFINITIONS:
		var label: String = definition.display_name
		_check(not identifiers.has(definition.object_id), label + ": identificador único")
		identifiers[definition.object_id] = true
		_check(definition.texture != null and definition.texture.get_width() <= 256,
			label + ": textura final cargada con límite móvil de 256 píxeles")
		await _new_world()
		var object := _object(definition)
		_check(object.can_be_picked_up() and not object.can_cause_thrown_damage(), label + ": libre no causa daño")
		var hand := Marker2D.new()
		hand.position = Vector2(0, 320)
		hand.scale.x = -1.0
		_world.add_child(hand)
		object.pick_up(hand)
		_check(object.state == ThrowableObject.State.HELD and object.get_parent() == hand
			and object.collision_layer == 0 and not object.can_cause_thrown_damage(), label + ": agarrado a la mano sin colisión ni daño")
		object.pick_up(_world)
		_check(object.get_parent() == hand, label + ": no se puede recoger dos veces")
		object.release(-1, Vector2.ZERO)
		_check(object.get_parent() == _world and object.velocity.x < 0 and object.can_cause_thrown_damage()
			and object.scale.is_equal_approx(Vector2.ONE),
			label + ": lanzamiento a la izquierda conserva la escala física sin reflejo")
		object.reset_to_spawn()
		object.pick_up(hand)
		object.release(1, Vector2.ZERO, false)
		_check(not object.can_cause_thrown_damage(), label + ": soltar por daño no es un ataque")
		object.reset_to_spawn()
		var receiver := _receiver()
		await _step(2)
		_launch(object)
		await _step(55)
		_check(receiver.hits == 1 and not object.can_cause_thrown_damage(), label + ": un único impacto en el receptor")
		hand.queue_free()

	# La mayor velocidad del catálogo se barre frente a una pared de dos píxeles.
	await _new_world()
	_wall()
	var fast := _object(ThrowableCatalog.DEFINITIONS[2])
	await _step(2)
	_launch(fast)
	await _step(35)
	_check(fast.position.x < 90 and not fast.can_cause_thrown_damage(), "la piña rápida no atraviesa una pared fina")

	# Arcos y comportamientos distintos sobre el mismo suelo físico.
	for index in [0, 1, 4]:
		await _new_world()
		var object := _object(ThrowableCatalog.DEFINITIONS[index])
		_launch(object, Vector2(0, 350))
		await _step(55)
		if index == 1:
			_check(object.state == ThrowableObject.State.FREE and absf(object.velocity.x) < 1,
				"el canto pesado se detiene al aterrizar")
		else:
			_check(object.state == ThrowableObject.State.THROWN and object.position.x > 350
				and object.can_cause_thrown_damage(), "barril/hielo siguen activos al rodar o deslizar: %d" % index)
	for index in [2, 5]:
		await _new_world()
		var object := _object(ThrowableCatalog.DEFINITIONS[index])
		var bounce_count: Array[int] = [0]
		object.bounced.connect(func(): bounce_count[0] += 1)
		_launch(object, Vector2(0, 350))
		await _step(240)
		_check(bounce_count[0] == object.definition.maximum_bounces,
			"rebotes reales limitados a %d para %s" % [object.definition.maximum_bounces, object.definition.display_name])

	await _new_world()
	var vase := _object(ThrowableCatalog.DEFINITIONS[3])
	await _step(60)
	_check(vase.state == ThrowableObject.State.FREE and vase.visible, "la vasija libre aterriza intacta")
	_launch(vase)
	await _step(70)
	_check(vase.state == ThrowableObject.State.BROKEN and not vase.visible and vase.collision_layer == 0
		and not vase.can_be_picked_up(), "la vasija lanzada se rompe y deja de colisionar o recogerse")

	await _new_world()
	var recovery := _object(ThrowableCatalog.DEFINITIONS[3])
	recovery.respawn_delay = 0.15
	recovery.recovery_bounds = Rect2(-200, -600, 3600, 1800)
	var returns: Array[int] = [0]
	recovery.returned_to_spawn.connect(func(): returns[0] += 1)
	_launch(recovery)
	await _step(90)
	_check(returns[0] == 1 and recovery.visible and recovery.can_be_picked_up()
		and absf(recovery.position.x) < 1, "el entrenamiento repone la vasija rota en su propio puesto")
	recovery.position.y = 1300.0
	await _step(2)
	_check(returns[0] == 2 and recovery.position.y < 400, "salir del área recupera el objeto en su puesto")

	await _new_world()
	var timed_definition: ThrowableDefinition = ThrowableCatalog.DEFINITIONS[0].duplicate()
	timed_definition.flight_seconds = 0.05
	var expired := _object(timed_definition)
	_launch(expired)
	await _step(8)
	_check(expired.state == ThrowableObject.State.FREE and not expired.can_cause_thrown_damage(),
		"caducar el tiempo de vuelo desactiva el daño aunque siga moviéndose")

	await _new_world()
	var dropped := _object(ThrowableCatalog.DEFINITIONS[0])
	var receiver := _receiver()
	_launch(dropped)
	await _step(35)
	dropped.respawn_delay = 0.1
	dropped._settle()
	var hand := Marker2D.new()
	hand.position = Vector2(20, 200)
	_world.add_child(hand)
	dropped.pick_up(hand)
	await _step(25)
	_check(dropped.state == ThrowableObject.State.HELD and dropped.get_parent() == hand,
		"volver a recoger cancela la reposición automática")
	_check(receiver.hits == 1, "un objeto agotado no repite el impacto mientras permanece junto a la diana")

	_world.queue_free()
	await _step(2)
	var main: Node2D = load("res://game/features/player/practice.tscn").instantiate()
	root.add_child(main)
	await _step(4)
	var count: int = 0
	for child in main.get_node("PracticeStage").get_children():
		if child is ThrowableObject:
			count += 1
	_check(count == 6, "los seis recursos están disponibles en el entrenamiento principal")
	main.queue_free()
	await _step(2)
	print("RESULTADO OBJETOS: %d comprobaciones, %d fallos" % [_checks, _failures])
	quit(0 if _failures == 0 else 1)
