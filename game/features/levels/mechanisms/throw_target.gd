class_name ForestThrowTarget
extends StaticBody2D
## Rotura tipo cristal: celdas irregulares de Voronoi, destello y caída.
## Las piezas conservan el PNG, no tienen colisión y no afectan a la lógica del puente.

signal activated(mechanism_id: StringName)

const TEXTURE: Texture2D = preload("res://game/assets/textures/environments/bosque_esmeralda/mechanisms/throw_target_v001.png")
const BREAK_SECONDS: float = 0.72
const SHARD_COUNT: int = 19

var definition: RootBridgeDefinition
var active: bool = true
var _sprite: Sprite2D
var show_connection: bool = true
var _fragments: Node2D
var _break_tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	position = definition.target_position
	collision_layer = 64
	collision_mask = 8
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 58.0
	shape.shape = circle
	add_child(shape)
	_sprite = Sprite2D.new()
	_sprite.texture = TEXTURE
	_sprite.scale = Vector2.ONE * 136.0 / maxf(TEXTURE.get_width(), TEXTURE.get_height())
	var material := ShaderMaterial.new()
	material.shader = preload("res://game/features/player/sprite_alpha.gdshader")
	_sprite.material = material
	add_child(_sprite)


func receive_thrown_hit(object: ThrowableObject) -> void:
	if not active or not is_instance_valid(object) or not object.can_cause_thrown_damage():
		return
	break_apart()
	activated.emit(definition.mechanism_id)


func break_apart() -> void:
	if not active:
		return
	active = false
	set_deferred("collision_layer", 0)
	_sprite.hide()
	_clear_fragments()
	_fragments = Node2D.new()
	_fragments.name = "CrystalShards"
	add_child(_fragments)
	var rng := RandomNumberGenerator.new()
	# Semilla propia: geometría repetible en pruebas, sin tocar el RNG del juego.
	rng.seed = 1927 + int(absf(position.x) * 13.0) + int(absf(position.y) * 29.0)
	var source_size: Vector2 = TEXTURE.get_size()
	var seeds: PackedVector2Array = _shard_seeds(rng, source_size)
	_break_tween = create_tween().set_parallel(true)
	for index in seeds.size():
		var polygon: PackedVector2Array = _shard_cell(seeds, index, source_size)
		if polygon.size() < 3:
			continue
		var center := Vector2.ZERO
		for vertex in polygon:
			center += vertex
		center /= float(polygon.size())
		var shard := Polygon2D.new()
		shard.name = "Shard_%02d" % index
		var local_vertices := PackedVector2Array()
		var uv := PackedVector2Array()
		for vertex in polygon:
			local_vertices.append(vertex - center)
			uv.append(vertex + source_size * 0.5)
		shard.polygon = local_vertices
		shard.uv = uv
		shard.texture = TEXTURE
		shard.material = _sprite.material
		shard.modulate = Color(0.89, 0.96, 1.0)
		shard.scale = _sprite.scale
		shard.position = center * _sprite.scale
		_fragments.add_child(shard)
		# Arista brillante y fina que acompaña al vidrio durante el giro.
		var edge := Line2D.new()
		edge.points = local_vertices
		edge.closed = true
		edge.width = 1.4 / maxf(_sprite.scale.x, 0.001)
		edge.default_color = Color(0.81, 0.96, 1.0, 0.52)
		shard.add_child(edge)
		var outward: Vector2 = (center / maxf(source_size.x, source_size.y) + Vector2(rng.randf_range(-0.18, 0.18), rng.randf_range(-0.18, 0.18))).normalized()
		if outward.length_squared() < 0.01:
			outward = Vector2.from_angle(rng.randf_range(0.0, TAU))
		var force: float = rng.randf_range(28.0, 94.0)
		var burst: Vector2 = shard.position + outward * force + Vector2(rng.randf_range(-18.0, 18.0), rng.randf_range(-37.0, -13.0))
		var landed: Vector2 = burst + Vector2(rng.randf_range(-37.0, 37.0), rng.randf_range(74.0, 158.0))
		_break_tween.tween_property(shard, "position", burst, 0.19).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_break_tween.tween_property(shard, "position", landed, BREAK_SECONDS - 0.19).set_delay(0.19).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		_break_tween.tween_property(shard, "rotation", rng.randf_range(-2.6, 2.6), BREAK_SECONDS)
		_break_tween.tween_property(shard, "modulate:a", 0.0, 0.30).set_delay(BREAK_SECONDS - 0.30)
	# Una chispa fría muy breve subraya el punto de impacto.
	var flash := Polygon2D.new()
	flash.name = "ImpactFlash"
	flash.polygon = PackedVector2Array([Vector2(0, -15), Vector2(5, -5), Vector2(18, 0), Vector2(5, 5), Vector2(0, 15), Vector2(-5, 5), Vector2(-18, 0), Vector2(-5, -5)])
	flash.color = Color(0.83, 0.97, 1.0, 0.94)
	_fragments.add_child(flash)
	_break_tween.tween_property(flash, "scale", Vector2(2.1, 2.1), 0.13).set_trans(Tween.TRANS_CUBIC)
	_break_tween.tween_property(flash, "modulate:a", 0.0, 0.16)
	_break_tween.chain().tween_callback(_clear_fragments)
	queue_redraw()


func _shard_seeds(rng: RandomNumberGenerator, size: Vector2) -> PackedVector2Array:
	# Centro, primer anillo descompensado y segundo anillo de longitudes distintas:
	# NO hay ocho sectores iguales ni corte radial repetido.
	var seeds := PackedVector2Array()
	for index in SHARD_COUNT:
		if index == 0:
			seeds.append(Vector2(rng.randf_range(-0.07, 0.07) * size.x, rng.randf_range(-0.07, 0.07) * size.y))
			continue
		var inner: bool = index < 7
		var ring_index: int = index - (1 if inner else 7)
		var count: int = 6 if inner else 12
		var direction: float = TAU * float(ring_index) / float(count) + rng.randf_range(-0.19, 0.19)
		var distance: float = rng.randf_range(0.13, 0.29) if inner else rng.randf_range(0.33, 0.61)
		seeds.append(Vector2(cos(direction) * size.x, sin(direction) * size.y) * distance)
	return seeds


func _shard_cell(seeds: PackedVector2Array, index: int, size: Vector2) -> PackedVector2Array:
	# Recorte de Voronoi: cada fragmento es poligonal, irregular y sin huecos.
	var half: Vector2 = size * 0.5
	var cell := PackedVector2Array([Vector2(-half.x, -half.y), Vector2(half.x, -half.y), Vector2(half.x, half.y), Vector2(-half.x, half.y)])
	for other in seeds.size():
		if other == index:
			continue
		var normal: Vector2 = seeds[other] - seeds[index]
		var limit: float = (seeds[other].length_squared() - seeds[index].length_squared()) * 0.5
		cell = _clip_half_plane(cell, normal, limit)
		if cell.size() < 3:
			break
	return cell


func _clip_half_plane(polygon: PackedVector2Array, normal: Vector2, limit: float) -> PackedVector2Array:
	var clipped := PackedVector2Array()
	if polygon.is_empty():
		return clipped
	var previous: Vector2 = polygon[polygon.size() - 1]
	var previous_distance: float = previous.dot(normal) - limit
	for current in polygon:
		var current_distance: float = current.dot(normal) - limit
		if (previous_distance <= 0.0) != (current_distance <= 0.0):
			var fraction: float = previous_distance / (previous_distance - current_distance)
			clipped.append(previous.lerp(current, clampf(fraction, 0.0, 1.0)))
		if current_distance <= 0.0:
			clipped.append(current)
		previous = current
		previous_distance = current_distance
	return clipped


func restore_activated() -> void:
	# Herramientas de captura: representar una diana ya resuelta sin animación.
	_clear_fragments()
	active = false
	set_deferred("collision_layer", 0)
	_sprite.hide()
	queue_redraw()


func reset_to_intact() -> void:
	_clear_fragments()
	active = true
	set_deferred("collision_layer", 64)
	_sprite.show()
	queue_redraw()


func _clear_fragments() -> void:
	if _break_tween != null and _break_tween.is_running():
		_break_tween.kill()
	_break_tween = null
	if is_instance_valid(_fragments):
		remove_child(_fragments)
		_fragments.queue_free()
	_fragments = null


func _draw() -> void:
	# Poste y raíz pertenecen al escenario; no se añaden marcas ni insignias.
	draw_line(Vector2(0, 54), Vector2(0, 72), Color("382b1c"), 13, true)
	if show_connection:
		var connection: Vector2 = definition.bridge_rect.position - position + Vector2(14, 13)
		draw_polyline(PackedVector2Array([Vector2(0, 65), Vector2(32, 76), connection]), Color("59482d"), 7, true)
