class_name CoralStage
extends ForestStage
## Las balsas, llaves y faroles comparten la lógica de las aventuras existentes.

const SAND: Texture2D = preload("res://game/assets/textures/environments/costa_de_coral/sandbank_v001.webp")
const SHELL_TOTEM: Texture2D = preload("res://game/assets/textures/environments/costa_de_coral/shell_totem_v001.webp")
const HEART: Texture2D = preload("res://game/assets/ui/hud_heart.svg")
const GROTTO_WIDTH: float = 1540.0
const REWARD_OFFSET := Vector2(920, 199)

var _bonus_taken: bool = false
var _bonus_sprite: Sprite2D


func _init() -> void:
	sand_texture = SAND
	ferry_decks = true


func _add_ground_with_tunnel(rect: Rect2) -> void:
	# El recurso ya separa las orillas de la gruta, como las de los canales.
	_add_platform(rect, true)


func _build_scenery() -> void:
	var shore := Node2D.new()
	shore.z_index = -9
	shore.draw.connect(_draw_shore.bind(shore))
	add_child(shore)
	for at in checkpoint_positions():
		var lantern: Sprite2D = _prop(3, at + Vector2(0, 6), 180.0, -2)
		lantern.modulate = Color("ffd9ab")


func _draw_shore(shore: Node2D) -> void:
	var cave: Vector2 = DEFINITION.secret_grove
	for i in range(1, DEFINITION.ground_sections.size()):
		var left: float = DEFINITION.ground_sections[i - 1].end.x
		var width: float = DEFINITION.ground_sections[i].position.x - left
		if width <= 0.0:
			continue
		if cave.x > 0.0 and left > cave.x and left < cave.x + GROTTO_WIDTH:
			continue
		shore.draw_rect(Rect2(left, 710, width, 860), Color("2b8891"))
		shore.draw_rect(Rect2(left, 710, width, 17), Color("9de0cf"))
		shore.draw_rect(Rect2(left, 745, width, 825), Color("246878"))
	if cave.x >= 0.0:
		shore.draw_rect(Rect2(cave + Vector2(0, -65), Vector2(GROTTO_WIDTH, 400)), Color("23545b"))
		shore.draw_rect(Rect2(cave + Vector2(212, 95), Vector2(1270, 240)), Color("1f444c"))


func _build_secret() -> void:
	var entrance: Vector2 = DEFINITION.secret_grove
	if entrance.x < 0.0:
		return
	_add_platform(Rect2(entrance + Vector2(-230, -92), Vector2(155, 58)), false)
	# 65 px libres sobre la arena: Diego pasa agachado y puede levantarse al caer.
	_add_platform(Rect2(entrance + Vector2(0, -170), Vector2(1320, 105)), true)
	_add_platform(Rect2(entrance + Vector2(198, 255), Vector2(1342, 265)), true)
	# Peldaños sin techo bajo a la salida. Todos admiten saltar desde abajo.
	for rock in [Rect2(1155, 162, 150, 55), Rect2(1320, 84, 155, 65),
			Rect2(1455, 24, 100, 60)]:
		_add_platform(Rect2(entrance + rock.position, rock.size), false)
	secret_totem = ForestSecretTotem.new()
	secret_totem.texture = SHELL_TOTEM
	secret_totem.position = entrance + Vector2(-90, 0)
	add_child(secret_totem)
	for offset in [350, 470, 590, 710, 830, 1030, 1130]:
		_add_collectible(entrance + Vector2(offset, 205))
	var reward: Vector2 = entrance + REWARD_OFFSET
	_bonus_sprite = Sprite2D.new()
	_bonus_sprite.texture = HEART
	_bonus_sprite.scale = Vector2.ONE * 52.0 / HEART.get_height()
	_bonus_sprite.position = reward
	_bonus_sprite.z_index = 1
	add_child(_bonus_sprite)
	_marker(reward, Vector2(62, 64), _collect_bonus)


func _collect_bonus(body: Node2D) -> void:
	if body != player or player.dead or completed or _bonus_taken:
		return
	_bonus_taken = true
	_bonus_sprite.hide()
	_on_secret_life_collected()


func _secret_life_taken() -> bool:
	return _bonus_taken
