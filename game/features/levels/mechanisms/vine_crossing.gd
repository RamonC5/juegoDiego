class_name ForestVineCrossing
extends Node2D
## Cinco lianas independientes oscilan sobre el barranco.
## Diego salta, se agarra al nudo, se balancea y vuelve a saltar entre ellas.

signal fell

const FIRST_VINE_X: float = 1700.0
const ANCHOR_XS: Array[float] = [1700.0, 2050.0, 2400.0, 2750.0, 3100.0]
const ANCHOR_Y: float = 110.0
const RAVINE_LEFT: float = 1900.0
const RAVINE_RIGHT: float = 3260.0

var vines: Array[ForestSwingingVine] = []
var player: DiegoPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	z_index = -2
	for index in ANCHOR_XS.size():
		var vine := ForestSwingingVine.new()
		vine.position = Vector2(ANCHOR_XS[index], ANCHOR_Y)
		# Fases distintas: las lianas vecinas nunca se mueven como un bloque.
		vine.phase_offset = float(index) * 0.83
		add_child(vine)
		vines.append(vine)
	queue_redraw()


func attach_player(hero: DiegoPlayer) -> void:
	player = hero
	for vine in vines:
		if not hero.swinging_vines.has(vine):
			hero.swinging_vines.append(vine)


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player) or player.dead or player.celebrating:
		return
	if player.global_position.x > global_position.x + RAVINE_LEFT \
			and player.global_position.x < global_position.x + RAVINE_RIGHT \
			and player.global_position.y > 775.0:
		fell.emit()


func reset_vines() -> void:
	for vine in vines:
		vine.reset_cycle()


func _draw() -> void:
	# Rama superior y hojas: continuidad reconocible sobre las cinco cuerdas.
	draw_line(Vector2(1430, ANCHOR_Y - 8), Vector2(3330, ANCHOR_Y - 8),
		Color("354c32"), 18.0, true)
	draw_line(Vector2(1430, ANCHOR_Y - 13), Vector2(3330, ANCHOR_Y - 13),
		Color("75924d"), 5.0, true)
	for index in 11:
		var x: float = 1530.0 + float(index) * 162.0
		var side: float = -1.0 if index % 2 == 0 else 1.0
		draw_line(Vector2(x, ANCHOR_Y - 10), Vector2(x + side * 30, ANCHOR_Y + 15),
			Color("4a7747"), 7.0, true)
		draw_circle(Vector2(x + side * 30, ANCHOR_Y + 15), 13.0,
			Color("88b265"))
