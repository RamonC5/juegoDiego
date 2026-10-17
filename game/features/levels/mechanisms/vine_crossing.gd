class_name ForestVineCrossing
extends Node2D
## Barranco obligatorio: liana ascendente y cinco dianas elásticas.
## La salida no se desbloquea con temporizadores ni indicadores flotantes.

signal fell

const VINE_X: float = 1780.0
const TARGETS: Array[Vector2] = [
	Vector2(2040, 390), Vector2(2300, 345), Vector2(2560, 400),
	Vector2(2820, 355), Vector2(3080, 405),
]
var targets: Array[ForestVineTarget] = []
var player: DiegoPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	z_index = -2
	for point in TARGETS:
		var target := ForestVineTarget.new()
		target.position = point
		add_child(target)
		targets.append(target)
	queue_redraw()

func attach_player(hero: DiegoPlayer) -> void:
	player = hero
	# El gesto de saltar mantenido trepa; soltarlo libera la liana.
	hero.vine_climb_zone = Rect2(global_position.x + VINE_X - 85.0, 285, 170, 355)

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player) or player.dead or player.celebrating:
		return
	if player.global_position.x > global_position.x + 1880.0 \
			and player.global_position.x < global_position.x + 3260.0 \
			and player.global_position.y > 775.0:
		fell.emit()

func reset_targets() -> void:
	for target in targets:
		target.reset_target()

func _draw() -> void:
	# Liana visible desde el suelo; relieve natural sin caracteres ni UI flotante.
	draw_line(Vector2(VINE_X, 110), Vector2(VINE_X, 622), Color("35462a"), 18.0, true)
	draw_line(Vector2(VINE_X - 4, 110), Vector2(VINE_X - 4, 622), Color("84a85b"), 5.0, true)
	for j in 9:
		var y: float = 160.0 + float(j) * 51.0
		var side: float = -1.0 if j % 2 == 0 else 1.0
		draw_line(Vector2(VINE_X, y), Vector2(VINE_X + side * 29, y - 19), Color("547a47"), 5.0, true)
		draw_circle(Vector2(VINE_X + side * 29, y - 19), 9.0, Color("8eaf67"))
	# Dos ramas altas indican la continuidad entre las dianas suspendidas.
	draw_line(Vector2(1510, 110), Vector2(3260, 110), Color("455c35"), 16.0, true)
	for point in TARGETS:
		draw_line(Vector2(point.x, 110), Vector2(point.x, point.y - 112), Color("557749"), 8.0, true)
