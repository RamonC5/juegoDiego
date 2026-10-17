class_name ForestVineCrossing
extends Node2D
## Cinco lianas independientes oscilan sobre el barranco.
## Diego salta, se agarra al nudo, se balancea y vuelve a saltar entre ellas.

signal fell

const BRANCH: Texture2D = preload("res://game/assets/textures/environments/bosque_esmeralda/mechanisms/root_bridge_v001.png")
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
	# Rama de raíces y musgo del mismo atlas que puentes y plataformas.
	var source := Rect2(BRANCH.get_size() * Vector2(0.007, 0.26), BRANCH.get_size() * Vector2(0.987, 0.52))
	draw_texture_rect_region(BRANCH, Rect2(1430, ANCHOR_Y - 28, 1900, 72), source)
