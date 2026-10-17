class_name ForestThrowTarget
extends StaticBody2D
## Diana destructible: los fragmentos son visuales y nunca bloquean al jugador.

signal activated(mechanism_id: StringName)

const TEXTURE: Texture2D = preload("res://game/assets/textures/environments/bosque_esmeralda/mechanisms/throw_target_v001.png")
const BREAK_SECONDS: float = 0.65

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
	_fragments = Node2D.new()
	add_child(_fragments)
	_break_tween = create_tween().set_parallel(true)
	# Ocho sectores recortan el mismo raster: conservan textura y centro de la diana.
	var radius: float = maxf(TEXTURE.get_width(), TEXTURE.get_height()) * 0.72
	var center: Vector2 = TEXTURE.get_size() / 2.0
	for index in 8:
		var angle: float = TAU * index / 8.0
		var polygon := PackedVector2Array([Vector2.ZERO])
		for corner in 5:
			polygon.append(Vector2.from_angle(angle + TAU / 8.0 * corner / 4.0) * radius)
		var shard := Polygon2D.new()
		shard.polygon = polygon
		var uv := PackedVector2Array()
		for vertex in polygon:
			uv.append(vertex + center)
		shard.uv = uv
		shard.texture = TEXTURE
		shard.material = _sprite.material
		shard.scale = _sprite.scale
		_fragments.add_child(shard)
		var direction: Vector2 = Vector2.from_angle(angle + PI / 8.0)
		var destination: Vector2 = direction * 65.0 + Vector2(0, 105)
		_break_tween.tween_property(shard, "position", destination, BREAK_SECONDS).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		_break_tween.tween_property(shard, "rotation", direction.x * 1.5, BREAK_SECONDS)
		_break_tween.tween_property(shard, "modulate:a", 0.0, 0.3).set_delay(BREAK_SECONDS - 0.3)
	_break_tween.chain().tween_callback(_clear_fragments)
	queue_redraw()


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
