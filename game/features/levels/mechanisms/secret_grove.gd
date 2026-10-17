class_name ForestSecretGrove
extends Node2D
## Sendero bajo el bosque: agacharse abre la trampilla y el rastro guía al oeste.
## El ascensor reutiliza la plataforma móvil del bosque sin controles nuevos.

signal bonus_collected

const HATCH_HALF_WIDTH: float = 110.0
const CAVE_LEFT: float = -1500.0
const CAVE_RIGHT: float = 390.0
const LIFT_X: float = -1270.0
const REWARD_POSITION: Vector2 = Vector2(-730, 420)
const PROPS: Texture2D = preload("res://game/assets/textures/environments/bosque_esmeralda/forest_props_v001.png")

var hero: DiegoPlayer
var lift: ForestMovingPlatform
var hatch: ForestPlatform
var hatch_shape: CollisionShape2D
var reward_zone: Area2D
var reward_taken: bool = false
var _reward_sprite: Sprite2D
var _phase: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	process_physics_priority = -15
	z_index = -2
	# ForestStage conserva el techo y recorta el volumen sólido bajo el sendero.
	hatch = _add_surface(-HATCH_HALF_WIDTH, HATCH_HALF_WIDTH * 2.0)
	hatch_shape = hatch.get_child(0) as CollisionShape2D
	# El fondo del pozo queda dentro de los límites seguros de la cámara.
	var floor := ForestPlatform.new()
	floor.position = Vector2(CAVE_LEFT, 480.0)
	floor.dimensions = Vector2(CAVE_RIGHT - CAVE_LEFT, 120.0)
	floor.is_ground = true
	add_child(floor)
	# Extremos cerrados para que no haya caídas al vacío dentro del secreto.
	for wall_x in [CAVE_LEFT, CAVE_RIGHT - 32.0]:
		var wall := ForestPlatform.new()
		wall.position = Vector2(wall_x, 64.0)
		wall.dimensions = Vector2(32.0, 416.0)
		wall.is_ground = true
		add_child(wall)
	var definition := MovingPlatformDefinition.new()
	definition.platform_id = &"ascensor_hojas_secreto"
	definition.display_name = "Ascensor de la gruta oculta"
	definition.start_position = Vector2(LIFT_X, 435)
	definition.end_position = Vector2(LIFT_X, -5)
	definition.width = 170.0
	definition.travel_seconds = 3.2
	definition.stop_seconds = 2.1
	lift = ForestMovingPlatform.new()
	lift.definition = definition
	add_child(lift)
	lift.z_index = 1 # El ascensor se dibuja delante del fondo de la gruta.
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
	_reward_sprite = Sprite2D.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = PROPS
	atlas.region = Rect2(PROPS.get_size() * Vector2(0.55, 0), PROPS.get_size() * Vector2(0.45, 0.515))
	_reward_sprite.texture = atlas
	_reward_sprite.scale = Vector2.ONE * 80.0 / atlas.region.size.y
	_reward_sprite.position = REWARD_POSITION + Vector2(0, 10)
	var alpha := ShaderMaterial.new()
	alpha.shader = preload("res://game/features/levels/mechanisms/forest_asset_alpha.gdshader")
	_reward_sprite.material = alpha
	_reward_sprite.modulate = Color(1.18, 1.12, 0.8)
	add_child(_reward_sprite)
	set_process(true)
	set_physics_process(true)


func _add_surface(local_x: float, width: float) -> ForestPlatform:
	var platform := ForestPlatform.new()
	platform.position = Vector2(local_x, 0)
	platform.dimensions = Vector2(width, 64)
	platform.is_ground = false
	add_child(platform)
	return platform


func contains_underworld(at: Vector2) -> bool:
	var local := to_local(at)
	return local.x >= CAVE_LEFT and local.x <= CAVE_RIGHT and local.y > -10.0


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(hero) or not is_instance_valid(hatch_shape):
		return
	var local := to_local(hero.global_position)
	# El mismo gesto de agacharse (pantalla/teclado) revela la trampilla.
	# Se restringe a la superficie para evitar abrirla al caminar abajo.
	var open_hatch: bool = not hero.dead and absf(local.x) < 67.0 \
		and local.y > -75.0 and local.y < 44.0 and hero.controls.held(&"crouch")
	if hatch_shape.disabled != open_hatch:
		hatch_shape.set_deferred("disabled", open_hatch)
	# El cuerpo puede aparecer ya dentro del área tras un ascensor o reaparición:
	# la proximidad 2D complementa body_entered sin conceder premio en superficie.
	if not reward_taken and not hero.dead and is_instance_valid(reward_zone):
		var torso: Vector2 = hero.global_position + Vector2(0, -46)
		if torso.distance_to(reward_zone.global_position) < 82.0:
			_on_reward_body_entered(hero)


func _on_reward_body_entered(body: Node2D) -> void:
	if reward_taken or not body is DiegoPlayer or body.dead:
		return
	reward_taken = true
	_reward_sprite.hide()
	reward_zone.set_deferred("monitoring", false)
	bonus_collected.emit()
	queue_redraw()


func _process(delta: float) -> void:
	_phase += delta
	if absf(_phase) > 100000.0:
		_phase = 0.0
	if not reward_taken:
		_reward_sprite.position.y = REWARD_POSITION.y + 10.0 + sin(_phase * 2.0) * 3.0
	queue_redraw()


func _draw() -> void:
	# Raíces, hojas y capas de tierra diferencian el escondite del vacío.
	draw_rect(Rect2(CAVE_LEFT, 0, CAVE_RIGHT - CAVE_LEFT, 480), Color("14241d"))
	var terrain_size: Vector2 = ForestPlatform.TERRAIN.get_size()
	var source_height: float = terrain_size.y * 0.40
	var rock_scale: float = 208.0 / source_height
	# Mantener la proporción de las rocas, también en la última pieza del mosaico.
	for row in 2:
		var rock_x: float = CAVE_LEFT + 14.0
		while rock_x < CAVE_RIGHT - 14.0:
			var rock_width: float = minf(terrain_size.x * rock_scale, CAVE_RIGHT - 14.0 - rock_x)
			var source := Rect2(0, terrain_size.y * 0.58, rock_width / rock_scale, source_height)
			draw_texture_rect_region(ForestPlatform.TERRAIN, Rect2(rock_x, 64 + row * 208, rock_width, 208), source, Color(0.35, 0.41, 0.35))
			rock_x += rock_width
	# Helechos raster del mismo atlas que la superficie.
	var fern_source := Rect2(PROPS.get_size() * Vector2(0.55, 0), PROPS.get_size() * Vector2(0.45, 0.515))
	for i in 13:
		var x: float = CAVE_LEFT + 45.0 + float(i) * 140.0
		draw_texture_rect_region(PROPS, Rect2(x, 60, 110, 100), fern_source, Color(0.43, 0.57, 0.43, 0.65))
	if not reward_taken:
		draw_circle(REWARD_POSITION, 46, Color(0.90, 0.84, 0.40, 0.10))
		draw_circle(REWARD_POSITION, 30, Color(0.94, 0.88, 0.49, 0.12))
