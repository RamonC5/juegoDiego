extends Node2D
## Visor de autoría de los siete diseños. No introduce nuevos enemigos en el bosque.

var visuals: Array[EnemyVisual] = []
var playing: bool = true
var _status: Label


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("132a30"))
	var title := Label.new()
	title.text = "Super Diego · Movimiento de enemigos"
	title.position = Vector2(36, 18)
	title.add_theme_font_size_override("font_size", 30)
	add_child(title)
	for index in EnemyMotionProfiles.IDS.size():
		var id: String = EnemyMotionProfiles.IDS[index]
		var visual := EnemyVisual.new()
		visual.configure(id, load("res://game/assets/textures/characters/%s/idle_v001.png" % id))
		var column: int = index % 4
		var row: int = index / 4
		var holder := Node2D.new()
		holder.position = Vector2(165 + column * 312, 320 + row * 280)
		add_child(holder)
		var atlas := visual.texture as AtlasTexture
		visual.scale = Vector2.ONE * minf(240.0 / atlas.region.size.x, 205.0 / atlas.region.size.y)
		holder.add_child(visual)
		visuals.append(visual)
		var name_label := Label.new()
		name_label.text = EnemyMotionProfiles.NAMES[index]
		name_label.position = Vector2(-130, 12)
		name_label.size.x = 260
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 24)
		holder.add_child(name_label)
	var controls := HBoxContainer.new()
	controls.position = Vector2(36, 665)
	controls.add_theme_constant_override("separation", 20)
	add_child(controls)
	var pause_button := Button.new()
	pause_button.text = "Pausar / Reanudar"
	pause_button.custom_minimum_size = Vector2(230, 44)
	pause_button.pressed.connect(func(): playing = not playing)
	controls.add_child(pause_button)
	var reduce := CheckButton.new()
	reduce.text = "Movimiento reducido"
	reduce.custom_minimum_size.y = 44
	reduce.toggled.connect(func(value: bool):
		for visual in visuals:
			visual.reduced_motion = value
	)
	controls.add_child(reduce)
	_status = Label.new()
	_status.text = "Visor de animaciones · 5 diseños aún sin IA de nivel"
	controls.add_child(_status)
	pause_button.grab_focus()


func _process(delta: float) -> void:
	if playing:
		for visual in visuals:
			visual.advance(delta, 65.0, not visual.profile.flying)
