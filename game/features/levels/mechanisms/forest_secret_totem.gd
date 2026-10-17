class_name ForestSecretTotem
extends Node2D
## Madera, musgo y helechos raster del bosque. Señal ambiental sin colisión.

const TEXTURE: Texture2D = preload("res://game/assets/textures/environments/bosque_esmeralda/mechanisms/secret_totem_v001.png")
const ANIMATION_RADIUS: float = 390.0

var hero: DiegoPlayer
var _phase: float = 0.0
var _nearby: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	var alpha := ShaderMaterial.new()
	alpha.shader = preload("res://game/features/levels/mechanisms/forest_asset_alpha.gdshader")
	material = alpha
	z_index = 4
	queue_redraw()


func _process(delta: float) -> void:
	var near: bool = is_instance_valid(hero) and hero.global_position.distance_squared_to(global_position) < ANIMATION_RADIUS * ANIMATION_RADIUS
	if not near:
		if _nearby:
			_nearby = false
			queue_redraw()
		return
	_nearby = true
	_phase = fposmod(_phase + delta, TAU * 100.0)
	queue_redraw()


func _draw() -> void:
	# La raíz queda a ras del suelo. El tronco no se estira ni oscila entero.
	draw_texture_rect(TEXTURE, Rect2(-71, -190, 142, 203), false)
	if _nearby:
		# Las tallas y la hojarasca también señalan el acceso, sin destellos.
		var pulse: float = 0.05 + 0.025 * sin(_phase * 1.5)
		draw_circle(Vector2(0, -71), 17.0, Color(0.75, 0.91, 0.53, pulse))
