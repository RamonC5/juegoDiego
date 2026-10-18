class_name ForestSpringPad
extends ForestVineTarget
## Seta elástica: aterrizar impulsa; conserva una corrección de doble salto.
## Reutiliza la seta raster del atlas del bosque y el contacto unilateral existente.

const IMPULSE: float = 1040.0
var _mushroom: Sprite2D
var _base_scale := Vector2.ONE


func _ready() -> void:
	super._ready()
	var atlas := AtlasTexture.new()
	atlas.atlas = ForestStage.PROPS
	atlas.region = Rect2(atlas.atlas.get_size() * Vector2(0.79, 0.373), atlas.atlas.get_size() * Vector2(0.125, 0.125))
	_mushroom = Sprite2D.new()
	_mushroom.texture = atlas
	_mushroom.centered = false
	_mushroom.offset = Vector2(-atlas.region.size.x / 2.0, 0)
	_base_scale = Vector2(176.0, 80.0) / atlas.region.size
	_mushroom.scale = _base_scale
	var material := ShaderMaterial.new()
	material.shader = preload("res://game/features/player/sprite_alpha.gdshader")
	_mushroom.material = material
	add_child(_mushroom)


func bounce(hero: DiegoPlayer) -> bool:
	if not super.bounce(hero):
		return false
	hero.velocity.y = -IMPULSE
	return true


func _physics_process(delta: float) -> void:
	if intact:
		return
	elapsed += delta
	var squash: float = sin(clampf(elapsed / 0.45, 0.0, 1.0) * PI)
	_mushroom.scale = _base_scale * Vector2(1.0 + 0.18 * squash, 1.0 - 0.32 * squash)
	if elapsed >= 0.45:
		reset_target()


func reset_target() -> void:
	super.reset_target()
	if is_instance_valid(_mushroom):
		_mushroom.scale = _base_scale


func _draw() -> void:
	pass
