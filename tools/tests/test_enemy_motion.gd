extends SceneTree
## Reproducción, pausa, espejo, aislamiento de instancias y combate con la malla real.

var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)


func _run() -> void:
	for id in EnemyMotionProfiles.IDS:
		var source: Texture2D = load("res://game/assets/textures/characters/%s/idle_v001.png" % id)
		var visual := EnemyVisual.new()
		visual.configure(id, source)
		root.add_child(visual)
		check(visual._mesh.mesh.get_surface_count() == 1 and source.get_width() > 0, "%s raster y malla válidos" % id)
		var first: PackedFloat32Array = visual.pose_angles.duplicate()
		visual.advance(0.12, 70.0, not visual.profile.flying)
		check(first != visual.pose_angles, "%s mueve articulaciones, no solo el sprite completo" % id)
		check(visual.pose_offsets[0].length() > 0.001, "%s añade movimiento localizado al miembro" % id)
		check(visual._motion_material.get_shader_parameter("region_origin") == visual.profile.region.position, "%s usa UV locales del recorte" % id)
		for angle in visual.pose_angles:
			check(is_finite(angle) and absf(angle) <= 0.3, "%s amplitud controlada" % id)
		visual.face_left(true)
		check(visual._mesh.scale.x == -1.0, "%s refleja la malla con el personaje" % id)
		visual.face_left(false)
		check(visual._mesh.scale.x == 1.0, "%s recupera orientación derecha" % id)
		var previous: float = visual.phase
		visual.advance(0.0, 70.0, true)
		check(visual.phase == previous, "%s no avanza sin tiempo" % id)
		visual.phase = TAU - 0.0001
		visual.advance(0.0, 70.0, true)
		var end: PackedFloat32Array = visual.pose_angles.duplicate()
		var end_offset: PackedVector2Array = visual.pose_offsets.duplicate()
		visual.phase = 0.0001
		visual.advance(0.0, 70.0, true)
		for index in visual.profile.joints.size():
			check(absf(end[index] - visual.pose_angles[index]) < 0.001, "%s cierra el bucle sin salto" % id)
			check(end_offset[index].distance_to(visual.pose_offsets[index]) < 0.001, "%s traslación cierra el bucle" % id)
		visual.phase = 0.7
		visual.advance(0.0, 70.0, true)
		var normal: PackedFloat32Array = visual.pose_angles.duplicate()
		visual.reduced_motion = true
		visual.advance(0.0, 70.0, true)
		check(absf(visual.pose_angles[0]) < absf(normal[0]), "%s reduce el movimiento secundario" % id)
		check(visual.pose_offsets[0].length() < 0.08, "%s limita el desplazamiento de extremidad" % id)
		var other := EnemyVisual.new()
		other.configure(id, source)
		root.add_child(other)
		check(other._mesh.mesh == visual._mesh.mesh and other._motion_material != visual._motion_material, "%s comparte geometría sin mezclar fases" % id)
		visual.queue_free()
		other.queue_free()
	await process_frame
	var enemy := ForestEnemy.new()
	enemy.kind = "moflete"
	root.add_child(enemy)
	enemy.set_physics_process(false)
	check(enemy.has_visible_art() and enemy._visual is EnemyVisual, "el bosque usa el raster articulado")
	var body_position: Vector2 = enemy.position
	var sensor_position: Vector2 = enemy._stomp.position
	enemy._visual.advance(0.2, 100.0, true)
	check(enemy.position == body_position and enemy._stomp.position == sensor_position, "mover miembros conserva colisiones y pisotón")
	var frozen: float = enemy._visual.phase
	paused = true
	await process_frame
	await process_frame
	check(enemy._visual.phase == frozen, "pausa real congela animación")
	paused = false
	enemy.defeat(false)
	await create_timer(0.18).timeout
	check(enemy._visual.scale.y < enemy._scale * 0.3 and enemy._visual.phase == frozen, "derrota detiene miembros y comprime toda la malla")
	await create_timer(0.5).timeout
	check(not is_instance_valid(enemy), "derrota libera el enemigo y su material")
	print("RESULTADO ANIMACIÓN: %d comprobaciones, %d fallos" % [checks, failures])
	quit(0 if failures == 0 else 1)
