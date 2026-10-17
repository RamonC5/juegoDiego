class_name ForestSecretGrove
extends Node2D
## Cámara de hojas bajo el sendero: agacharse abre el suelo falso.
## El ascensor reutiliza la plataforma móvil del bosque sin controles nuevos.

signal bonus_collected

const HATCH_HALF_WIDTH: float = 110.0
const CAVE_LEFT: float = -260.0
const CAVE_RIGHT: float = 390.0

var hero: DiegoPlayer
var lift: ForestMovingPlatform
var hatch: ForestPlatform
var hatch_shape: CollisionShape2D
var reward_zone: Area2D
var reward_taken: bool = false
var _phase: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	process_physics_priority = -15
	z_index = -2
	# Tierra firme de superficie; el único acceso se abre manteniendo agacharse.
	_add_surface(-260.0, 150.0)
	_add_surface(110.0, 280.0)
	hatch = _add_surface(-110.0, 220.0)
	hatch_shape = hatch.get_child(0) as CollisionShape2D
	# El fondo del pozo queda dentro de los límites seguros de la cámara.
	var floor := ForestPlatform.new()
	floor.position = Vector2(CAVE_LEFT, 480.0)
	floor.dimensions = Vector2(CAVE_RIGHT - CAVE_LEFT, 120.0)
	floor.is_ground = true
	add_child(floor)
	var definition := MovingPlatformDefinition.new()
	definition.platform_id = &"ascensor_hojas_secreto"
	definition.display_name = "Ascensor de la gruta oculta"
	definition.start_position = Vector2(0, 435)
	definition.end_position = Vector2(0, -5)
	definition.width = 170.0
	definition.travel_seconds = 3.2
	definition.stop_seconds = 2.1
	lift = ForestMovingPlatform.new()
	lift.definition = definition
	add_child(lift)
	reward_zone = Area2D.new()
	reward_zone.position = Vector2(215, 430)
	reward_zone.collision_layer = 32
	reward_zone.collision_mask = 2
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 32.0
	shape.shape = circle
	reward_zone.add_child(shape)
	reward_zone.body_entered.connect(_on_reward_body_entered)
	add_child(reward_zone)
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
	return local.x >= CAVE_LEFT - 20.0 and local.x <= CAVE_RIGHT + 20.0 and local.y > -10.0


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
	reward_zone.set_deferred("monitoring", false)
	bonus_collected.emit()
	queue_redraw()


func _process(delta: float) -> void:
	_phase += delta
	if absf(_phase) > 100000.0:
		_phase = 0.0
	queue_redraw()


func _draw() -> void:
	# Raíces, hojas y capas de tierra diferencian el escondite del vacío.
	draw_rect(Rect2(CAVE_LEFT, 0, CAVE_RIGHT - CAVE_LEFT, 480), Color("14241d"))
	draw_rect(Rect2(CAVE_LEFT + 14, 42, CAVE_RIGHT - CAVE_LEFT - 28, 418), Color("233629"))
	for i in 18:
		var x: float = CAVE_LEFT + 26.0 + float((i * 83) % 590)
		var y: float = 70.0 + float((i * 113) % 365)
		var root := Color("6d5b36", 0.45) if i % 3 == 0 else Color("6e9e50", 0.55)
		draw_line(Vector2(x, y), Vector2(x + 30, y + 24), root, 4.0, true)
	for i in 25:
		var x: float = CAVE_LEFT + 22.0 + float((i * 41) % 600)
		var y: float = 410.0 + float((i * 17) % 52)
		var leaf_color: Color = Color("a9c86c") if i % 3 == 0 else Color("4b995a")
		draw_colored_polygon(PackedVector2Array([
			Vector2(x - 17, y + 7), Vector2(x, y - 12),
			Vector2(x + 18, y + 3), Vector2(x, y + 14)]), leaf_color)
	# Oscilación de la recompensa: brote luminoso, sin letras ni símbolos de interfaz.
	if not reward_taken:
		var center := Vector2(215, 430 + sin(_phase * 2.6) * 5.0)
		draw_circle(center, 40, Color(0.55, 1.0, 0.58, 0.12))
		draw_circle(center, 25, Color("f1d779"))
		draw_colored_polygon(PackedVector2Array([
			center + Vector2(0, 5), center + Vector2(-21, -9),
			center + Vector2(-11, -25), center + Vector2(2, -9)]), Color("8fde8c"))
		draw_colored_polygon(PackedVector2Array([
			center + Vector2(0, 5), center + Vector2(22, -13),
			center + Vector2(13, -27), center + Vector2(-2, -8)]), Color("b1ed98"))
		draw_line(center + Vector2(0, 8), center + Vector2(0, -17), Color("fff5b3"), 4.0, true)
