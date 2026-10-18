class_name AdventureIntro
extends Control
## Escenas laterales: recorrido, apoyos y acciones comparten el reloj.

const FRAMES: SpriteFrames = preload("res://game/features/player/diego_frames.tres")
const SCENES: Texture2D = preload("res://game/assets/textures/entrance/adventure_scenes_v001.png")
const RUN_SHEET: Texture2D = preload("res://game/assets/textures/characters/diego/intro_run_v001.png")
const BEAT_SECONDS := 4.0
const RUN_STRIDE := 132.0
var _scales: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://game/features/player/animation_scales.json"))
var reduced_motion: bool = false
var clock: float = 0.0
var current_beat: int = -1
var actor: AnimatedSprite2D
var _previous_island: TextureRect
var _island: TextureRect
var _rope: Line2D
var _prop: Sprite2D
var _caption: Label
var _place: Label
var _stage_rect := Rect2()
var _shade: TextureRect
var _ground_enemy: EnemyVisual
var _flying_enemy: EnemyVisual
var _ground_root: Node2D
var _flying_root: Node2D
var _frames: SpriteFrames


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	_previous_island = _backdrop()
	_island = _backdrop()
	_shade = TextureRect.new()
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.34, 0.56, 1.0])
	gradient.colors = PackedColorArray([Color("071e29fa"), Color("071e29ed"), Color("071e2955"), Color("071e2912")])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2(0.0, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	_shade.texture = texture
	_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_shade)
	_ground_root = Node2D.new()
	add_child(_ground_root)
	_ground_enemy = EnemyVisual.new()
	_ground_root.add_child(_ground_enemy)
	_ground_enemy.configure("moflete", preload("res://game/assets/textures/characters/moflete/idle_v001.png"))
	_flying_root = Node2D.new()
	add_child(_flying_root)
	_flying_enemy = EnemyVisual.new()
	_flying_root.add_child(_flying_enemy)
	_flying_enemy.configure("noctilo", preload("res://game/assets/textures/characters/noctilo/idle_v001.png"))
	_rope = Line2D.new()
	_rope.width = 5
	_rope.default_color = Color("d5bd78")
	_rope.end_cap_mode = Line2D.LINE_CAP_ROUND
	add_child(_rope)
	_frames = _make_frames()
	actor = AnimatedSprite2D.new()
	actor.sprite_frames = _frames
	actor.centered = false
	actor.speed_scale = 0.0
	actor.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var material := ShaderMaterial.new()
	material.shader = preload("res://game/ui/menus/intro_actor.gdshader")
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


func _backdrop() -> TextureRect:
	var image := TextureRect.new()
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_SCALE
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(image)
	return image


func _make_frames() -> SpriteFrames:
	var frames: SpriteFrames = FRAMES.duplicate()
	frames.clear(&"run")
	# Recortes del PNG intacto y raíz común por fila; no recentrar cada silueta.
	var regions: Array[Rect2] = [
		Rect2(35, 12, 408, 436), Rect2(520, 12, 324, 441),
		Rect2(937, 12, 357, 436), Rect2(1391, 12, 378, 436),
		Rect2(35, 454, 396, 424), Rect2(518, 454, 331, 429),
		Rect2(937, 454, 367, 424), Rect2(1398, 454, 371, 423),
	]
	for index in regions.size():
		var region: Rect2 = regions[index]
		var cell_origin := Vector2([0, 443, 887, 1330][index % 4], 0 if index < 4 else 438)
		var atlas := AtlasTexture.new()
		atlas.atlas = RUN_SHEET
		atlas.region = region
		atlas.margin = Rect2(region.position - cell_origin + Vector2(290, 453), Vector2(1024, 1024) - region.size)
		atlas.filter_clip = true
		frames.add_frame(&"run", atlas)
	frames.set_animation_speed(&"run", 10.0)
	_scales.run = 112.0 / 430.0
	return frames


func _label(font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color("071e29"))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label


func _layout() -> void:
	_stage_rect = Rect2(Vector2(size.x * 0.45, size.y * 0.12), Vector2(size.x * 0.55, size.y * 0.70))
	for image in [_island, _previous_island, _shade]:
		image.position = Vector2.ZERO
		image.size = size
	_place.position = Vector2(_stage_rect.position.x, size.y * 0.85)
	_place.size = Vector2(_stage_rect.size.x, 28)
	_caption.position = _place.position + Vector2(0, 30)
	_caption.size = Vector2(_stage_rect.size.x, 40)
	_update_actor()


func restart() -> void:
	clock = 0.0
	current_beat = -1
	_update_beat(0)


func _scene_texture(index: int) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = SCENES
	var cell_size: Vector2 = SCENES.get_size() / Vector2(2, 4)
	atlas.region = Rect2(Vector2(index % 2, index / 2) * cell_size, cell_size)
	atlas.filter_clip = true
	return atlas


func _update_beat(index: int) -> void:
	current_beat = index
	var world: Dictionary = WorldCatalog.WORLDS[index]
	_island.texture = _scene_texture(index)
	_previous_island.texture = _scene_texture((index + 7) % 8)
	_place.text = world.name.to_upper()
	_caption.text = "¡Que no te atrape Moflete!" if index == 0 else world.beat
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
	_update_enemies(delta if not reduced_motion else 0.0)
	queue_redraw()


func _jump(action: Dictionary, seconds: float, takeoff: float, duration: float, height: float) -> void:
	var flight: float = (seconds - takeoff) / duration
	if flight >= 0.0 and flight < 1.0:
		action.pose = &"jump_up" if flight < 0.5 else &"fall"
		action.time = flight * 0.22 if flight < 0.5 else (flight - 0.5) * 0.24
		action.lift = 4.0 * height * flight * (1.0 - flight)
		action.lean = lerpf(-0.075, 0.065, smoothstep(0.0, 1.0, flight))
	elif flight >= 1.0 and seconds < takeoff + duration + 0.18:
		action.pose = &"land"
		action.time = seconds - takeoff - duration
		var impact: float = sin(float(action.time) / 0.18 * PI)
		action.stretch = Vector2(1.0 + impact * 0.035, 1.0 - impact * 0.05)
	elif seconds > takeoff - 0.12 and seconds < takeoff:
		var weight: float = sin((seconds - takeoff + 0.12) / 0.12 * PI)
		action.stretch = Vector2(1.0 + weight * 0.025, 1.0 - weight * 0.035)


func sample_action(index: int, seconds: float) -> Dictionary:
	var u: float = clampf(seconds / BEAT_SECONDS, 0.0, 1.0)
	var result := {"pose": &"run", "time": seconds, "lift": 0.0, "lean": -0.025, "stretch": Vector2.ONE, "travel": u}
	match index:
		0:
			_jump(result, seconds, 1.45, 0.82, 83.0)
		1:
			_jump(result, seconds, 1.10, 1.05, 116.0)
		2:
			result.pose = &"carry_run"
		3:
			if seconds >= 1.35 and seconds < 1.69:
				result.pose = &"land"
				result.time = (seconds - 1.35) * 0.45
			result.lean = -0.025 + sin(u * TAU) * 0.045
		4:
			# Integral de frenada coseno: distancia y velocidad continuas al lanzar.
			var q: float = clampf((seconds - 0.82) / 1.0, 0.0, 1.0)
			result.travel = (seconds - 0.5 * (q - sin(q * TAU) / TAU)) / (BEAT_SECONDS - 0.5)
			if seconds < 1.02:
				result.pose = &"carry_run"
			elif seconds < 1.53:
				result.pose = &"throw"
				result.time = (seconds - 1.02) / 0.51 * 0.34
		5:
			result.pose = &"vine_hang"
			result.lean = 0.0
		6:
			_jump(result, seconds, 1.0, 1.4, 145.0)
			if seconds >= 1.0 and seconds < 2.4:
				var t: float = seconds - 1.0
				result.lift = 380.0 * t - 425.0 * t * t
				if t >= 0.4:
					var second: float = t - 0.4
					result.lift = 84.0 + 341.0 * second - 425.0 * second * second
					result.pose = &"double_jump" if second < 0.16 else (&"jump_up" if second < 0.401 else &"fall")
					result.time = second * 0.32
		7:
			_jump(result, seconds, 1.25, 1.03, 108.0)
	return result


func _update_actor() -> void:
	if not is_instance_valid(actor):
		return
	var seconds: float = fmod(clock, BEAT_SECONDS)
	var action: Dictionary = sample_action(maxi(0, current_beat), seconds)
	if reduced_motion:
		action = {"pose": &"victory", "time": 0.0, "lift": 0.0, "lean": 0.0, "stretch": Vector2.ONE, "travel": 0.52}
	var pose: StringName = action.pose
	var magnification: float = minf(size.x / 1280.0, size.y / 720.0) * 1.65
	var base := Vector2(size.x * lerpf(0.47, 1.04, float(action.travel)), size.y * 0.82)
	base.y -= float(action.lift) * magnification
	actor.scale = Vector2.ONE * float(_scales.get(String(pose), 0.19)) * magnification * Vector2(action.stretch)
	actor.offset = Vector2(-512, -906)
	actor.rotation = float(action.lean)
	_rope.visible = pose == &"vine_hang" and not reduced_motion
	if _rope.visible:
		var angle: float = sin(seconds * TAU / 3.8 - 0.8) * 0.62
		var origin := Vector2(size.x * 0.73, size.y * 0.21)
		base = origin + Vector2(sin(angle), cos(angle)) * 153.0 * magnification
		actor.offset = Vector2(-697, -149)
		actor.rotation = -angle
		_rope.points = PackedVector2Array([origin, base])
	actor.position = base
	var animation_time: float = float(action.time)
	if pose in [&"run", &"carry_run"]:
		var distance: float = float(action.travel) * size.x * 0.57 / maxf(magnification, 0.01)
		animation_time = distance / RUN_STRIDE * _frames.get_frame_count(pose) / _frames.get_animation_speed(pose)
	_set_pose(pose, animation_time)
	var opacity: float = 1.0 if reduced_motion else smoothstep(0.0, 0.22, seconds) * (1.0 - smoothstep(BEAT_SECONDS - 0.24, BEAT_SECONDS, seconds))
	actor.modulate.a = opacity
	_rope.modulate.a = opacity
	var dissolve: float = 1.0 if reduced_motion or clock < BEAT_SECONDS else smoothstep(0.0, 0.32, seconds)
	_island.modulate.a = dissolve
	_previous_island.visible = dissolve < 1.0
	_previous_island.modulate.a = 1.0 - dissolve
	_update_prop(seconds, base, magnification, opacity)
	# También al cambiar accesibilidad, redimensionar o buscar una captura sin proceso.
	_update_enemies(0.0)


func _set_pose(pose: StringName, seconds: float) -> void:
	var count: int = _frames.get_frame_count(pose)
	var cursor: int = int(maxf(0.0, seconds) * _frames.get_animation_speed(pose))
	var index: int = cursor % count if _frames.get_animation_loop(pose) else mini(cursor, count - 1)
	# Un único dibujo opaco evita duplicar manos y pies al fundir siluetas.
	actor.animation = pose
	actor.set_frame_and_progress(index, 0.0)
	actor.pause()


func _update_prop(seconds: float, base: Vector2, magnification: float, opacity: float) -> void:
	_prop.visible = not reduced_motion and current_beat in [2, 4]
	_prop.scale = Vector2.ONE * (35.0 * magnification / _prop.texture.get_width())
	_prop.position = base + Vector2(29, -65) * magnification
	_prop.rotation = actor.rotation
	_prop.modulate.a = opacity
	if current_beat == 4 and seconds >= 1.25:
		var flight: float = seconds - 1.25
		var release: Dictionary = sample_action(4, 1.25)
		_prop.position = Vector2(size.x * lerpf(0.47, 1.04, float(release.travel)), size.y * 0.82) + Vector2(29, -65) * magnification
		_prop.position += Vector2(flight * 235.0, -flight * 235.0 + flight * flight * 270.0) * magnification
		_prop.rotation = flight * 7.0
		_prop.modulate.a *= 1.0 - smoothstep(0.62, 0.80, flight)
		_prop.visible = flight < 0.80


func _update_enemies(delta: float) -> void:
	var seconds: float = fmod(clock, BEAT_SECONDS)
	var scale_factor: float = minf(size.x / 1280.0, size.y / 720.0)
	var opacity: float = smoothstep(0.0, 0.28, seconds) * (1.0 - smoothstep(BEAT_SECONDS - 0.24, BEAT_SECONDS, seconds))
	_ground_root.visible = not reduced_motion and current_beat == 0
	_flying_root.visible = not reduced_motion and current_beat in [4, 5, 6]
	_ground_root.position = Vector2(actor.position.x - 145.0 * scale_factor, size.y * 0.82)
	_ground_root.scale = Vector2.ONE * (105.0 * scale_factor / _ground_enemy.texture.get_height())
	_ground_root.modulate.a = opacity
	_ground_enemy.advance(delta, size.x * 0.57 / BEAT_SECONDS, true, true)
	_flying_root.position = Vector2(size.x * (0.94 - seconds / BEAT_SECONDS * 0.27), size.y * 0.35 + sin(seconds * 2.1) * 22.0 * scale_factor)
	_flying_root.scale = Vector2.ONE * (96.0 * scale_factor / _flying_enemy.texture.get_height())
	_flying_root.modulate.a = opacity
	_flying_enemy.face_left(true)
	_flying_enemy.advance(delta, -85.0, false, true)
