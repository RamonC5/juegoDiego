class_name RootBridge
extends StaticBody2D
## Pasarela que crece una sola vez. La colisión aparece al terminar, sin transportar al jugador.

signal opened(mechanism_id: StringName)

enum State { CLOSED, OPENING, OPEN }

const TEXTURE: Texture2D = preload("res://game/assets/textures/environments/bosque_esmeralda/mechanisms/root_bridge_v001.png")
const OPEN_SECONDS: float = 0.6

var definition: RootBridgeDefinition
var state: State = State.CLOSED
var _shape: CollisionShape2D
var _progress: float = 0.0
var _finishing: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	collision_layer = 1
	collision_mask = 0
	position = definition.bridge_rect.position
	z_index = -1
	_shape = CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(definition.bridge_rect.size.x, 24)
	_shape.shape = rectangle
	_shape.position = Vector2(rectangle.size.x / 2.0, 12)
	_shape.disabled = true
	add_child(_shape)
	set_physics_process(false)
	queue_redraw()


func activate() -> void:
	if state != State.CLOSED:
		return
	state = State.OPENING
	set_physics_process(true)


func restore_open() -> void:
	# Reaparecer no repite la animación ni vuelve a emitir una activación ya resuelta.
	state = State.OPEN
	_progress = 1.0
	_finishing = false
	_shape.set_deferred("disabled", false)
	set_physics_process(false)
	queue_redraw()


func _physics_process(delta: float) -> void:
	_progress = minf(1.0, _progress + delta / OPEN_SECONDS)
	queue_redraw()
	if _progress >= 1.0 and not _finishing:
		_finishing = true
		_finish_open.call_deferred()


func _finish_open() -> void:
	if state != State.OPENING:
		return
	_shape.disabled = false
	state = State.OPEN
	set_physics_process(false)
	queue_redraw()
	opened.emit(definition.mechanism_id)


func _draw() -> void:
	var dimensions: Vector2 = definition.bridge_rect.size
	var size: Vector2 = TEXTURE.get_size()
	# Región normalizada de alfa: el PNG original conserva sus márgenes transparentes.
	var source := Rect2(size * Vector2(0.007, 0.26), size * Vector2(0.987, 0.52))
	if state == State.CLOSED:
		# Un brote recogido y la unión de ambas orillas anuncian el paso pendiente.
		draw_texture_rect_region(TEXTURE, Rect2(-8, 7, 68, dimensions.y), source, Color(0.8, 0.83, 0.68))
		for x in range(80, int(dimensions.x) - 20, 36):
			draw_line(Vector2(x, 10), Vector2(x + 14, 10), Color(0.77, 0.72, 0.48, 0.42), 2.0, true)
		return
	var amount: float = smoothstep(0.0, 1.0, _progress)
	var visible_source := Rect2(source.position, Vector2(source.size.x * amount, source.size.y))
	# El musgo principal se alinea con la superficie física y sobresale unos pocos píxeles.
	draw_texture_rect_region(TEXTURE, Rect2(-10, -8, (dimensions.x + 20) * amount, dimensions.y), visible_source)
