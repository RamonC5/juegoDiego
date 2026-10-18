extends SceneTree
## Rotura, pausa y reconstrucción de todas las dianas al volver al farol.

var main: Node2D
var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	run.call_deferred()


func step(frames: int = 2) -> void:
	for frame in frames:
		await physics_frame
		await process_frame


func check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures += 1
	print("%s %s" % ["OK" if value else "FALLO", description])


func run() -> void:
	main = load("res://game/boot/main.tscn").instantiate()
	main.collection_progress = CollectionProgress.new("user://collection-test_breakable_targets-%d-%d.json" % [OS.get_process_id(), Time.get_ticks_usec()])
	root.add_child(main)
	await step(4)
	var stage: ForestStage = main.stage
	var hero: DiegoPlayer = main.player
	for enemy in stage.enemies:
		enemy.set_physics_process(false)
	var target: ForestThrowTarget = stage.throw_targets[0]
	var object := ThrowableObject.new()
	object.definition = ThrowableCatalog.DEFINITIONS[2]
	stage.add_child(object)
	var hand := Marker2D.new()
	stage.add_child(hand)
	var activations: Array[int] = [0]
	target.activated.connect(func(_id: StringName): activations[0] += 1)
	target.receive_thrown_hit(object)
	check(target.active and target._sprite.visible, "un objeto libre no rompe la diana")
	object.pick_up(hand)
	target.receive_thrown_hit(object)
	check(target.active, "un objeto sostenido no rompe la diana")
	object.release(1, Vector2.ZERO)
	target.receive_thrown_hit(object)
	check(not target.active and not target._sprite.visible, "el impacto válido rompe y oculta la diana entera")
	check(target._fragments != null and target._fragments.get_child_count() == ForestThrowTarget.SHARD_COUNT + 1, "la diana genera 19 cristales distintos y un destello")
	var widths := PackedFloat32Array()
	var unique_shapes: Dictionary = {}
	for shard_index in ForestThrowTarget.SHARD_COUNT:
		var piece := target._fragments.get_child(shard_index) as Polygon2D
		check(piece != null and piece.texture == ForestThrowTarget.TEXTURE and piece.polygon.size() >= 3, "fragmento %d preserva textura con recorte irregular" % shard_index)
		if piece != null:
			var bounds: Rect2 = _bounds(piece.polygon)
			widths.append(bounds.size.x)
			unique_shapes[str(roundf(bounds.size.x / 10.0)) + ":" + str(piece.polygon.size())] = true
	check(unique_shapes.size() >= 8, "los trozos tienen geometrías variadas, no sectores idénticos")
	var narrowest: float = INF
	var widest: float = 0.0
	for width in widths:
		narrowest = minf(narrowest, width)
		widest = maxf(widest, width)
	check(widest > narrowest * 1.6, "los trozos tienen tamaños claramente distintos")
	target.receive_thrown_hit(object)
	check(activations[0] == 1, "el mismo impacto no activa dos veces la diana rota")
	await step(4)
	check(target.collision_layer == 0, "la diana rota deja pasar los siguientes proyectiles")
	var fragment := target._fragments.get_child(0) as Polygon2D
	var position_before: Vector2 = fragment.position
	main._open_menu("Pausa", true)
	await step(5)
	check(fragment.position == position_before, "la pausa detiene los fragmentos de cristal")
	main._resume()
	await step(48)
	check(target._fragments == null and not target._sprite.visible, "al terminar no quedan fragmentos ni disco entero")
	check(stage.bridges[0].state == RootBridge.State.OPEN, "la rotura abre el puente")
	# Conservar la diana del puente anterior y reparar solo el tramo posterior.
	stage._on_checkpoint(hero, 1)
	var future: ForestThrowTarget = stage.throw_targets[1]
	future.break_apart()
	stage._on_mechanism_activated(future.definition.mechanism_id)
	var gate_target: ForestThrowTarget = stage.throw_targets[stage.bridges.size()]
	gate_target.break_apart()
	stage.level_keys[0]._on_body_entered(hero)
	hero._die()
	main._resume()
	await step(3)
	check(not target.active and not target._sprite.visible and target.collision_layer == 0, "la diana anterior al farol conserva su estado resuelto")
	check(gate_target.active and gate_target._sprite.visible and gate_target._fragments == null, "el reintento repara también una diana de raíces con rotura pendiente")
	check(stage.bridges[0].state == RootBridge.State.OPEN and not stage.bridges[0]._shape.disabled and stage.collected_keys.has(0), "se conserva el puente anterior junto a la llave")
	check(stage.bridges[1].state == RootBridge.State.CLOSED and future.active and future._sprite.visible, "se repliega y rearma el puente posterior al farol")
	check(stage.activated_mechanisms == [target.definition.mechanism_id], "solo queda registrada la activación del tramo anterior")
	check(stage.root_gates.all(func(g: ForestRootGate): return not g.is_open and g.activated.is_empty()), "las barreras de dos marcas también se rearman")
	object.reset_to_spawn()
	object.pick_up(hand)
	object.release(1, Vector2.ZERO)
	future.receive_thrown_hit(object)
	check(not future.active and activations[0] == 1, "la diana posterior reparada vuelve a funcionar sin repetir la anterior")
	check(stage.activated_mechanisms.count(future.definition.mechanism_id) == 1 and stage.bridges[1].state == RootBridge.State.OPENING, "la diana posterior vuelve a desplegar su puente una sola vez")
	stage.respawn_player()
	stage.respawn_player()
	await step(3)
	check(not target.active and stage.throw_targets.slice(1).all(func(t: ForestThrowTarget): return t.active and t._sprite.visible and t._fragments == null), "varios reintentos conservan el tramo anterior y reparan el siguiente sin duplicar fragmentos")
	check(_has_no_badges(stage), "el escenario carece de iconos flotantes")
	check(not main.touch._move_hint.visible and not main.touch._action_hint.visible, "los gestos permanecen activos sin iconos en pantalla")
	main.queue_free()
	await step(3)
	await preload("res://tools/tests/audio_cleanup.gd").flush(self)
	print("RESULTADO DIANAS: %d comprobaciones, %d fallos" % [checks, failures])
	quit(1 if failures else 0)


func _bounds(vertices: PackedVector2Array) -> Rect2:
	var rect := Rect2(vertices[0], Vector2.ZERO)
	for point in vertices:
		rect = rect.expand(point)
	return rect


func _has_no_badges(node: Node) -> bool:
	var script: Script = node.get_script()
	if script != null and script.resource_path.ends_with("world_cue.gd"):
		return false
	for child in node.get_children():
		if not _has_no_badges(child):
			return false
	return true

