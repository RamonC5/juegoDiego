class_name ForestCanopySecret
extends Node2D
## Acceso manual por liana, cinco copas y descenso físico al sendero.

signal bonus_collected
signal hint_requested(text: String)

const CROWNS: Array[Rect2] = [
	Rect2(150, -660, 440, 55), Rect2(690, -700, 440, 55),
	Rect2(1230, -650, 440, 55), Rect2(1770, -680, 440, 55),
	Rect2(2310, -630, 440, 55),
]
const DESCENT: Array[Rect2] = [
	Rect2(2850, -440, 220, 45), Rect2(3150, -250, 220, 45),
	Rect2(3450, -80, 220, 45),
]
const REWARD_POSITION := Vector2(2530, -690)
const ROUTE_END: float = 3670.0
const PROPS: Texture2D = preload("res://game/assets/textures/environments/bosque_esmeralda/forest_props_v001.png")

var hero: DiegoPlayer
var vine: ForestSwingingVine
var totem: ForestSecretTotem
var reward_taken: bool = false
var reward_zone: Area2D
var _reward_sprite: Sprite2D
var _hint_shown: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	vine = ForestSwingingVine.new()
	vine.position = Vector2(0, -950)
	vine.length = 800.0
	vine.swing_amplitude = 0.04
	add_child(vine)
	totem = ForestSecretTotem.new()
	totem.position = Vector2(-150, 0)
	add_child(totem)
	for rect in CROWNS:
		# Árbol completo: la copa soporta el paso y el tronco llega al suelo.
		var tree := _prop(Vector2(rect.get_center().x, 0), -rect.position.y, false)
		tree.z_index = -3
		_add_branch(rect)
	for rect in DESCENT:
		_add_branch(rect)
	reward_zone = Area2D.new()
	reward_zone.position = REWARD_POSITION
	reward_zone.collision_layer = 32
	reward_zone.collision_mask = 2
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 32.0
	shape.shape = circle
	reward_zone.add_child(shape)
	reward_zone.body_entered.connect(_on_reward_body_entered)
	add_child(reward_zone)
	_reward_sprite = _prop(REWARD_POSITION + Vector2(0, 45), 80, true)
	_reward_sprite.z_index = 3
	_reward_sprite.modulate = Color(1.18, 1.12, 0.8)


func _prop(at: Vector2, height: float, plant: bool) -> Sprite2D:
	var sprite := Sprite2D.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = PROPS
	atlas.region = Rect2(PROPS.get_size() * Vector2(0.55 if plant else 0.0, 0),
		PROPS.get_size() * Vector2(0.45 if plant else 0.55, 0.515))
	sprite.texture = atlas
	sprite.scale = Vector2.ONE * height / atlas.region.size.y
	sprite.position = at + Vector2(0, -height / 2.0)
	var alpha := ShaderMaterial.new()
	alpha.shader = preload("res://game/features/levels/mechanisms/forest_asset_alpha.gdshader")
	sprite.material = alpha
	add_child(sprite)
	return sprite


func _add_branch(rect: Rect2) -> void:
	var branch := ForestPlatform.new()
	branch.position = rect.position
	branch.dimensions = rect.size
	branch.z_index = -2
	add_child(branch)


func attach_player(player: DiegoPlayer) -> void:
	hero = player
	totem.hero = player
	if not player.swinging_vines.has(vine):
		player.swinging_vines.append(vine)


static func leaf_positions() -> Array[Vector2]:
	var positions: Array[Vector2] = [Vector2(0, -220), Vector2(0, -400), Vector2(0, -580)]
	for rect in CROWNS:
		for offset in [100.0, 220.0, 340.0]:
			positions.append(rect.position + Vector2(offset, -47))
	for rect in DESCENT:
		positions.append(rect.position + Vector2(110, -47))
	return positions


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(hero) or hero.dead:
		return
	var local := to_local(hero.global_position)
	if not _hint_shown and absf(local.x) < 320 and local.y > -200:
		_hint_shown = true
		hint_requested.emit("Secreto de las copas · Salta hacia la liana y mantén ARRIBA para trepar. Salta hacia la primera copa; las ramas del extremo bajan al sendero.")
	if not reward_taken and (hero.global_position + Vector2(0, -46)).distance_to(reward_zone.global_position) < 82:
		_on_reward_body_entered(hero)


func _on_reward_body_entered(body: Node2D) -> void:
	if reward_taken or not body is DiegoPlayer or body.dead:
		return
	reward_taken = true
	_reward_sprite.hide()
	reward_zone.set_deferred("monitoring", false)
	bonus_collected.emit()
