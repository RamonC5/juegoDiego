class_name AdventureIntro
extends Control
## Secuencias decorativas con poses reales, tiempo continuo y fundidos entre mundos.

const FRAMES: SpriteFrames = preload("res://game/features/player/diego_frames.tres")
var _scales: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://game/features/player/animation_scales.json"))
const BEAT_SECONDS := 3.2
var reduced_motion: bool = false
var clock: float = 0.0
var current_beat: int = -1
var actor: AnimatedSprite2D
var _next_frame: Sprite2D
var _previous_island: TextureRect
var _island: TextureRect
var _rope: Line2D
var _prop: Sprite2D
var _caption: Label
var _place: Label
var _stage_rect := Rect2()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	_previous_island = TextureRect.new()
	_previous_island.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_previous_island.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_previous_island.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_previous_island)
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
	actor.speed_scale = 0.0
	actor.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var material := ShaderMaterial.new()
	material.shader = preload("res://game/ui/menus/intro_actor.gdshader")
	actor.material = material
	add_child(actor)
	_next_frame = Sprite2D.new()
	_next_frame.centered = false
	_next_frame.material = material
	_next_frame.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(_next_frame)
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
	_island.pivot_offset = _island.size * 0.5
	_previous_island.position = _stage_rect.position
	_previous_island.size = _stage_rect.size
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
	var previous := AtlasTexture.new()
	previous.atlas = painting
	var previous_world: Dictionary = WorldCatalog.WORLDS[(index + 7) % 8]
	previous.region = Rect2(Vector2(previous_world.cell) * Vector2(painting.get_size()) / Vector2(4, 2), Vector2(painting.get_size()) / Vector2(4, 2))
	_previous_island.texture = previous
	_place.text = world.name.to_upper()
	_caption.text = world.beat
	# Las leyendas son decorativas y no anuncian cada cambio al lector de pantalla.
	_update_actor()


func set_reduced_motion(value: bool) -> void:
	reduced_motion = value
	if is_instance_valid(actor):
		_update_beat(0 if value else int(clock / BEAT_SECONDS) % WorldCatalog.WORLDS.size())


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


## Cada aventura encadena acciones completas; no mantiene el impulso congelado.
func sample_action(index: int, seconds: float) -> Dictionary:
	var u: float = clampf(seconds / BEAT_SECONDS, 0.0, 1.0)
	var result := {"pose": &"run", "time": seconds, "lift": 0.0, "lean": -0.035, "stretch": Vector2.ONE}
	match index:
		2:
			result.pose = &"carry_run"
		3:
			if u >= 0.20 and u < 0.67:
				result.pose = &"fall"
				result.lean = sin((u - 0.20) / 0.47 * TAU) * 0.22
				result.lift = sin((u - 0.20) / 0.47 * PI) * 16.0
			elif u >= 0.67 and u < 0.80:
				result.pose = &"land"
				result.time = seconds - BEAT_SECONDS * 0.67
		4:
			if u < 0.22:
				result.pose = &"carry_run"
			elif u < 0.47:
				result.pose = &"throw"
				result.time = seconds - BEAT_SECONDS * 0.22
				result.lean = sin((u - 0.22) / 0.25 * PI) * 0.12
		5:
			result.pose = &"vine_hang"
		7:
			if u >= 0.78:
				result.pose = &"victory"
				result.time = seconds - BEAT_SECONDS * 0.78
	if index in [1, 6, 7]:
		var start: float = 0.28 if index == 7 else 0.14
		var finish: float = 0.72 if index == 7 else 0.84
		if u >= start and u < finish:
			var flight: float = (u - start) / (finish - start)
			result.lift = sin(flight * PI) * (165.0 if index == 6 else 115.0)
			result.pose = &"jump_up" if flight < 0.46 else &"fall"
			result.time = seconds - start * BEAT_SECONDS
			result.lean = lerpf(-0.10, 0.08, flight)
			if index == 6 and flight >= 0.40 and flight < 0.68:
				result.pose = &"double_jump"
				result.time = seconds - (start + (finish - start) * 0.40) * BEAT_SECONDS
				result.lift += sin((flight - 0.40) / 0.28 * PI) * 28.0
		elif u >= finish and u < finish + 0.06:
			result.pose = &"land"
			result.time = seconds - finish * BEAT_SECONDS
	if result.pose in [&"run", &"carry_run"]:
		result.lift = absf(sin(seconds * 13.0 * PI)) * 3.0
	if result.pose == &"land":
		var impact: float = sin(clampf(float(result.time) / 0.19, 0.0, 1.0) * PI)
		result.stretch = Vector2(1.0 + impact * 0.06, 1.0 - impact * 0.06)
	return result


func _update_actor() -> void:
	if not is_instance_valid(actor):
		return
	var seconds: float = fmod(clock, BEAT_SECONDS)
	var phase: float = seconds / BEAT_SECONDS
	var action: Dictionary = sample_action(maxi(0, current_beat), seconds)
	if reduced_motion:
		action = {"pose": &"victory", "time": 0.0, "lift": 0.0, "lean": 0.0, "stretch": Vector2.ONE}
	var pose: StringName = action.pose
	var magnification: float = minf(size.x / 1280.0, size.y / 720.0) * 2.25
	var base: Vector2 = _stage_rect.position + _stage_rect.size * Vector2(0.5, 0.87)
	if not reduced_motion:
		base.x = _stage_rect.position.x + _stage_rect.size.x * lerpf(0.23, 0.77, phase)
		base.y -= float(action.lift) * magnification / 2.25
	actor.scale = Vector2.ONE * float(_scales.get(String(pose), 0.19)) * magnification * Vector2(action.stretch)
	actor.offset = Vector2(-512, -900)
	actor.rotation = float(action.lean)
	_rope.visible = pose == &"vine_hang" and not reduced_motion
	if _rope.visible:
		var angle: float = sin(phase * TAU - PI * 0.5) * 0.62
		var origin := _stage_rect.position + _stage_rect.size * Vector2(0.5, 0.12)
		base = origin + Vector2(sin(angle), cos(angle)) * 125.0 * magnification / 2.25
		actor.offset = Vector2(-697, -149)
		actor.rotation = -angle
		_rope.points = PackedVector2Array([origin, base])
	actor.position = base
	_set_pose(pose, float(action.time))
	# Actor oculto en los extremos: el cambio de viñeta no muestra un teletransporte.
	var opacity: float = 1.0 if reduced_motion else smoothstep(0.0, 0.16, seconds) * (1.0 - smoothstep(BEAT_SECONDS - 0.16, BEAT_SECONDS, seconds))
	actor.modulate.a *= opacity
	_next_frame.modulate.a *= opacity
	var dissolve: float = 1.0 if reduced_motion or clock < BEAT_SECONDS else smoothstep(0.0, 0.30, seconds)
	_island.modulate.a = dissolve
	_previous_island.visible = dissolve < 1.0
	_previous_island.modulate.a = 1.0 - dissolve
	_island.scale = Vector2.ONE if reduced_motion else Vector2.ONE * lerpf(1.0, 1.025, phase)
	_update_prop(seconds, base, magnification, opacity)


func _set_pose(pose: StringName, seconds: float) -> void:
	var count: int = FRAMES.get_frame_count(pose)
	var cursor: float = maxf(0.0, seconds) * FRAMES.get_animation_speed(pose)
	var frame_index: int = int(cursor)
	var next_index: int = frame_index + 1
	if FRAMES.get_animation_loop(pose):
		frame_index %= count
		next_index %= count
	else:
		frame_index = mini(frame_index, count - 1)
		next_index = mini(next_index, count - 1)
	var blend: float = smoothstep(0.35, 1.0, fmod(cursor, 1.0)) if next_index != frame_index else 0.0
	actor.play(pose)
	actor.set_frame_and_progress(frame_index, 0.0)
	actor.modulate.a = 1.0 - blend
	_next_frame.texture = FRAMES.get_frame_texture(pose, next_index)
	_next_frame.transform = actor.transform
	_next_frame.offset = actor.offset
	_next_frame.modulate.a = blend
	_next_frame.visible = blend > 0.0 and not reduced_motion
	if reduced_motion:
		actor.stop()
		actor.modulate.a = 1.0


func _update_prop(seconds: float, base: Vector2, magnification: float, opacity: float) -> void:
	_prop.visible = not reduced_motion and current_beat in [2, 4]
	_prop.scale = Vector2.ONE * (40.0 * magnification / _prop.texture.get_width())
	_prop.position = base + Vector2(29, -65) * magnification
	_prop.rotation = actor.rotation
	_prop.modulate.a = opacity
	if current_beat == 4 and seconds >= BEAT_SECONDS * 0.34:
		var flight: float = (seconds - BEAT_SECONDS * 0.34) / 1.35
		# La vasija continúa desde la mano en el instante de suelta.
		var release_x: float = _stage_rect.position.x + _stage_rect.size.x * lerpf(0.23, 0.77, 0.34)
		_prop.position = Vector2(release_x, _stage_rect.position.y + _stage_rect.size.y * 0.87) + Vector2(29, -65) * magnification
		_prop.position += Vector2(flight * 160.0, -flight * 155.0 + flight * flight * 140.0) * magnification / 2.25
		_prop.rotation = flight * TAU
		_prop.modulate.a *= 1.0 - smoothstep(0.82, 1.0, flight)
		_prop.visible = flight < 1.0

