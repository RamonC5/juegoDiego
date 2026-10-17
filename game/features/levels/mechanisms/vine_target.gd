class_name ForestVineTarget
extends StaticBody2D
## Diana elástica suspendida: impulsa al jugador, estalla y se regenera.
## Las colisiones no dependen del dibujo; sin letras ni iconos flotantes.

const RESET_SECONDS: float = 3.2
const BOUNCE_SPEED: float = 800.0

var intact: bool = true
var elapsed: float = 0.0
var support: CollisionShape2D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	collision_layer = 1
	collision_mask = 0
	z_index = -1
	support = CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(160, 20)
	support.shape = shape
	support.position = Vector2(0, 9)
	support.one_way_collision = true
	support.one_way_collision_margin = 8.0
	add_child(support)
	queue_redraw()

func bounce(hero: DiegoPlayer) -> bool:
	if not intact or hero.dead or hero.celebrating:
		return false
	intact = false
	elapsed = 0.0
	hero.velocity.y = -BOUNCE_SPEED
	# No alterar la forma desde una consulta de contactos físicos.
	support.set_deferred("disabled", true)
	hero.bounced.emit()
	queue_redraw()
	return true

func _physics_process(delta: float) -> void:
	if intact:
		return
	elapsed += delta
	if elapsed >= RESET_SECONDS:
		reset_target()
	else:
		queue_redraw()

func reset_target() -> void:
	intact = true
	elapsed = 0.0
	if is_instance_valid(support):
		support.set_deferred("disabled", false)
	queue_redraw()

func _draw() -> void:
	# Tallo y enganche orgánicos con un aro de cristal legible sin texto.
	draw_line(Vector2(0, -114), Vector2(0, -49), Color("4e6141"), 11.0, true)
	draw_line(Vector2(0, -114), Vector2(13, -86), Color("729457"), 4.0, true)
	if intact:
		draw_circle(Vector2(0, 8), 77.0, Color(0.06, 0.19, 0.23, 0.65))
		draw_circle(Vector2.ZERO, 72.0, Color("286875"))
		draw_circle(Vector2.ZERO, 56.0, Color("83c9b9"))
		draw_circle(Vector2.ZERO, 33.0, Color("285c70"))
		draw_circle(Vector2.ZERO, 15.0, Color("d6f1d5"))
		draw_arc(Vector2.ZERO, 72.0, 0.0, TAU, 40, Color("f0eed2"), 6.0, true)
		draw_arc(Vector2.ZERO, 45.0, 0.0, TAU, 40, Color("f4dfac"), 3.0, true)
	else:
		# Fragmentos de tamaños desiguales, con caída y transparencia progresiva.
		var fraction: float = minf(1.0, elapsed / 0.85)
		if fraction >= 1.0:
			return
		for i in 13:
			var angle: float = TAU * float(i) / 13.0 + sin(float(i) * 2.23) * 0.24
			var distance: float = 15.0 + 90.0 * fraction * (0.6 + 0.4 * sin(float(i) * 1.91) ** 2)
			var center := Vector2(cos(angle) * distance, sin(angle) * distance + 130.0 * fraction * fraction)
			var size: float = 7.0 + float((i * 11) % 21)
			var piece := PackedVector2Array([
				center + Vector2(-size, -size * 0.4),
				center + Vector2(size * 0.7, -size),
				center + Vector2(size, size * 0.9),
				center + Vector2(-size * 0.45, size * 0.55),
			])
			draw_colored_polygon(piece, Color(0.69, 0.94, 0.89, (1.0 - fraction) * 0.91))
