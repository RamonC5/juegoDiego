class_name ForestMovingPlatform
extends AnimatableBody2D
## Movimiento físico continuo; CharacterBody2D transporta al pasajero sin reparentarlo.

const TEXTURE: Texture2D = preload("res://game/assets/textures/environments/bosque_esmeralda/mechanisms/root_bridge_v001.png")

var definition: MovingPlatformDefinition
var elapsed: float = 0.0
var support: CollisionShape2D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	process_physics_priority = -10
	collision_layer = 1
	collision_mask = 0
	sync_to_physics = true
	position = definition.start_position
	z_index = -1
	support = CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(definition.width, 24.0)
	support.shape = rectangle
	support.position.y = 12.0
	# Atravesar desde abajo evita aplastar al jugador entre el tronco y el suelo.
	support.one_way_collision = true
	support.one_way_collision_margin = 8.0
	add_child(support)
	queue_redraw()


func _physics_process(delta: float) -> void:
	var half_cycle: float = definition.stop_seconds + definition.travel_seconds
	elapsed = fmod(elapsed + delta, half_cycle * 2.0)
	var returning: bool = elapsed >= half_cycle
	var phase: float = fmod(elapsed, half_cycle)
	var fraction: float = clampf((phase - definition.stop_seconds) / definition.travel_seconds, 0.0, 1.0)
	# Suavizar las salidas y llegadas, con una parada amplia en ambas orillas.
	var amount: float = (1.0 - cos(fraction * PI)) * 0.5
	if returning:
		amount = 1.0 - amount
	position = definition.start_position.lerp(definition.end_position, amount)


func reset_cycle() -> void:
	# ForestStage llama después de trasladar al jugador al farol, sobre tierra firme.
	elapsed = 0.0
	position = definition.start_position
	reset_physics_interpolation()


func carries(hero: DiegoPlayer) -> bool:
	if not hero.is_on_floor() or hero.dead:
		return false
	for index in hero.get_slide_collision_count():
		var contact: KinematicCollision2D = hero.get_slide_collision(index)
		if contact.get_collider() == self and contact.get_normal().y < -0.7:
			return true
	return false


func _draw() -> void:
	var size: Vector2 = TEXTURE.get_size()
	var source := Rect2(size * Vector2(0.007, 0.26), size * Vector2(0.987, 0.52))
	draw_texture_rect_region(TEXTURE, Rect2(-definition.width / 2.0 - 8.0, -8.0, definition.width + 16.0, 64.0), source)
	# Marca de apoyo clara, además del movimiento y de los rótulos de los puestos.
	draw_line(Vector2(-24, 7), Vector2(24, 7), Color("fff3cb"), 4.0, true)
