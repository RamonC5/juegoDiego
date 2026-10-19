class_name ForestFirefly
extends Node2D
## Ayudante opcional sin colisión, daño ni acciones nuevas.

const TEXTURE: Texture2D = preload("res://game/assets/textures/characters/luci/flutter_v001.png")
const EYE_PIVOTS: Array[Vector2] = [Vector2(470, 342), Vector2(460, 342), Vector2(470, 309), Vector2(461, 326)]
var hero: DiegoPlayer
var progress: CollectionProgress
var collectibles: Array[ForestCollectible] = []
var secret_position: Vector2 = Vector2(-1, -1)
var secret_found: bool = false
var secret_above: bool = false
var awake: bool = false
var hinting: bool = false
var _phase: float = 0.0
var _celebration: float = 0.0
var _magnet_seconds: float = 0.0
var _sprite: Sprite2D
var _frame: int = -1
var _frames: Array[AtlasTexture] = []
var _asleep_position: Vector2


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	z_index = 5
	_asleep_position = position
	_sprite = Sprite2D.new()
	_sprite.centered = false
	_sprite.material = ShaderMaterial.new()
	_sprite.material.shader = preload("res://game/features/player/sprite_alpha.gdshader")
	_sprite.scale = Vector2.ONE * 0.105
	add_child(_sprite)
	var cell: Vector2 = TEXTURE.get_size() / 2.0
	for index in 4:
		var atlas := AtlasTexture.new()
		atlas.atlas = TEXTURE
		atlas.region = Rect2(Vector2(index % 2, index / 2) * cell, cell)
		_frames.append(atlas)
	_set_frame(0)
	if progress != null:
		progress.changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	var was_awake: bool = awake
	awake = progress != null and progress.helper_unlocked()
	visible = not awake or progress.helper_enabled
	if awake and not was_awake and is_instance_valid(hero):
		position = hero.position + Vector2(-70, -135)
		celebrate()


func celebrate() -> void:
	_celebration = 1.6


func _set_frame(index: int) -> void:
	if _frame == index:
		return
	_frame = index
	_sprite.texture = _frames[index]
	_sprite.offset = -EYE_PIVOTS[index] * (TEXTURE.get_size().x / 1254.0)


func _process(delta: float) -> void:
	if not is_instance_valid(hero):
		return
	if not awake:
		visible = absf(hero.position.x - _asleep_position.x) < 1200.0
		# Puede volver a mostrarse al regresar: no detener el proceso.
		_set_frame(2)
		_sprite.modulate = Color(0.63, 0.68, 0.50, 0.72)
		return
	if not visible:
		return
	if secret_position.x >= 0.0 and ((secret_above and absf(hero.position.x - secret_position.x) < 400.0 and hero.position.y < secret_position.y - 300.0) or (not secret_above and hero.position.y > secret_position.y + 130.0)):
		secret_found = true
	_sprite.modulate = Color.WHITE
	if hero.dead:
		return
	_phase += delta
	_celebration = maxf(0.0, _celebration - delta)
	_set_frame(int(_phase * 12.0) % 4)
	var target: Vector2 = hero.position + Vector2(-hero.facing * 75.0, -135.0)
	hinting = not secret_found and secret_position.x >= 0.0 and hero.position.distance_to(secret_position) < 430.0
	if hinting:
		target = hero.position.lerp(secret_position + Vector2(0, -80), 0.35)
	if _celebration > 0.0:
		target += Vector2(sin(_phase * 5.0) * 28.0, -20.0)
	target.y += sin(_phase * 2.4) * 7.0
	position = target if position.distance_to(target) > 650.0 else position.lerp(target, 1.0 - exp(-delta * 6.0))
	_sprite.scale.x = absf(_sprite.scale.x) * hero.facing
	# Resplandor lento, sin destellos rápidos ni dependencia del sonido.
	_sprite.modulate = Color(1.0, 0.96, 0.76) if hinting else Color.WHITE
	_magnet_seconds = maxf(0.0, _magnet_seconds - delta)
	if _magnet_seconds <= 0.0 and not hero.celebrating:
		_magnet_seconds = 0.25
		_try_nearby_leaf()
	queue_redraw()


func _try_nearby_leaf() -> void:
	# Solo hojas junto a Diego; nunca cristales, fragmentos ni premios tras paredes.
	for item in collectibles:
		if item.taken or item.crystal or item.position.distance_to(hero.position + Vector2(0, -48)) > 68.0:
			continue
		var query := PhysicsRayQueryParameters2D.create(hero.global_position + Vector2(0, -48), item.global_position, 1)
		query.hit_from_inside = true
		if hero.get_world_2d().direct_space_state.intersect_ray(query).is_empty():
			item._on_body_entered(hero)
			return


func _draw() -> void:
	if awake and hinting:
		var strength: float = 0.07 + (sin(_phase * 2.0) + 1.0) * 0.025
		draw_circle(Vector2(-20 * hero.facing, 3), 34, Color(1.0, 0.85, 0.40, strength))

