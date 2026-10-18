class_name AdventureIntro
extends Control
## Montaje de poses existentes: no crea un jugador físico ni consume entradas del juego.

const FRAMES: SpriteFrames = preload("res://game/features/player/diego_frames.tres")
var _scales: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://game/features/player/animation_scales.json"))
const BEAT_SECONDS := 3.2
var reduced_motion: bool = false
var clock: float = 0.0
var current_beat: int = -1
var actor: AnimatedSprite2D
var _island: TextureRect
var _rope: Line2D
var _prop: Sprite2D
var _caption: Label
var _place: Label
var _stage_rect := Rect2()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_island = TextureRect.new()
	_island.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_island.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_island.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_island)
	_rope = Line2D.new()
	_rope.width = 7
	_rope.default_color = Color("d5bd78")
	_rope.end_cap_mode = Line2D.LINE_CAP_ROUND
	add_child(_rope)
	actor = AnimatedSprite2D.new()
	actor.sprite_frames = FRAMES
	actor.centered = false
	actor.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var material := ShaderMaterial.new()
	material.shader = preload("res://game/features/player/sprite_alpha.gdshader")
	actor.material = material
	add_child(actor)
	_prop = Sprite2D.new()
	_prop.texture = preload("res://game/features/objects/definitions/vasija_barro.tres").make_sprite_texture()
	_prop.material = material
	_prop.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(_prop)
	_place = _label(18, Color("ffd779"))
	_caption = _label(24, Color("fff4d5"))
	resized.connect(_layout)
	_layout()
	_update_beat(0)


func _label(font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label


func _layout() -> void:
	_stage_rect = Rect2(Vector2(size.x * 0.44, size.y * 0.12), Vector2(size.x * 0.53, size.y * 0.70))
	_island.position = _stage_rect.position
	_island.size = _stage_rect.size
	_place.position = Vector2(_stage_rect.position.x, size.y * 0.83)
	_place.size = Vector2(_stage_rect.size.x, 28)
	_caption.position = _place.position + Vector2(0, 30)
	_caption.size = Vector2(_stage_rect.size.x, 40)
	_update_actor()


func restart() -> void:
	clock = 0.0
	current_beat = -1
	_update_beat(0)


func _update_beat(index: int) -> void:
	current_beat = index
	var world: Dictionary = WorldCatalog.WORLDS[index]
	var painting: Texture2D = AdventureWorldMap.PAINTING
	var atlas := AtlasTexture.new()
	atlas.atlas = painting
	atlas.region = Rect2(Vector2(world.cell) * Vector2(painting.get_size()) / Vector2(4, 2), Vector2(painting.get_size()) / Vector2(4, 2))
	_island.texture = atlas
	_place.text = world.name.to_upper()
	_caption.text = world.beat
	# Las leyendas son decorativas y no anuncian cada cambio al lector de pantalla.
	actor.play(&"victory" if reduced_motion else world.pose)
	if reduced_motion:
		actor.stop()
	_update_actor()


func set_reduced_motion(value: bool) -> void:
	reduced_motion = value
	if is_instance_valid(actor):
		_update_beat(0 if value else maxi(0, current_beat))


func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	if not reduced_motion:
		clock += delta
		var index: int = int(clock / BEAT_SECONDS) % WorldCatalog.WORLDS.size()
		if index != current_beat:
			_update_beat(index)
	_update_actor()
	queue_redraw()


func _update_actor() -> void:
	if not is_instance_valid(actor):
		return
	var phase: float = fmod(clock, BEAT_SECONDS) / BEAT_SECONDS
	var base: Vector2 = _stage_rect.position + _stage_rect.size * Vector2(0.5, 0.87)
	var pose: StringName = actor.animation
	var magnification: float = minf(size.x / 1280.0, size.y / 720.0) * 2.25
	actor.scale = Vector2.ONE * float(_scales.get(String(pose), 0.19)) * magnification
	actor.offset = Vector2(-697, -1137) if pose == &"vine_hang" else Vector2(-512, -900)
	actor.rotation = 0
	if not reduced_motion:
		if pose in [&"run", &"carry_run"]:
			base.x += sin(phase * TAU) * 65
		elif pose in [&"jump_up", &"double_jump", &"fall"]:
			base.y -= sin(phase * PI) * 105
			base.x += (phase - 0.5) * 140
			if pose == &"fall":
				actor.rotation = sin(phase * TAU) * 0.12
		elif pose == &"vine_hang":
			var angle: float = sin(phase * TAU) * 0.32
			# Giro alrededor del agarre; manos en la misma cuerda desde el primer fotograma.
			actor.offset = Vector2(-697, -149)
			base = _stage_rect.position + _stage_rect.size * Vector2(0.5, 0.2) + Vector2(sin(angle), cos(angle)) * 95
			actor.rotation = -angle
	actor.position = base
	_prop.visible = pose in [&"carry_run", &"throw"] and not reduced_motion
	if _prop.visible:
		_prop.scale = Vector2.ONE * (40.0 * magnification / _prop.texture.get_width())
		_prop.position = base + Vector2(29, -65) * magnification
		_prop.rotation = 0
		if pose == &"throw" and phase > 0.25:
			var flight: float = (phase - 0.25) / 0.75
			_prop.position += Vector2(flight * 170, -sin(flight * PI) * 85)
			_prop.rotation = flight * TAU
	_rope.visible = pose == &"vine_hang" and not reduced_motion
	if _rope.visible:
		var origin := _stage_rect.position + _stage_rect.size * Vector2(0.5, 0.2)
		_rope.points = PackedVector2Array([origin, actor.position])
