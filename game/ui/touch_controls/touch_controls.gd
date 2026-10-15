class_name HeroTouchControls
extends Control
## Un puntero por contacto: moverse, saltar y actuar funcionan simultáneamente.

var input_source: PlayerInputSource
var settings: ControlSettings
var _centres: Dictionary = {}
var _pointers: Dictionary = {}
var _labels: Dictionary = {}
var _radius: float = 44.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_PAUSABLE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for action in [&"move_left", &"move_right", &"jump", &"grab_throw", &"run"]:
		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_theme_font_size_override("font_size", 19)
		add_child(label)
		_labels[action] = label
	_labels[&"move_left"].text = "←"
	_labels[&"move_right"].text = "→"
	_labels[&"jump"].text = "Saltar"
	_labels[&"grab_throw"].text = "Coger\nlanzar"
	_labels[&"run"].text = "Correr"
	resized.connect(refresh)
	settings.changed.connect(refresh)
	refresh()


func refresh() -> void:
	if not is_instance_valid(settings):
		return
	release_all()
	visible = settings.show_touch or DisplayServer.is_touchscreen_available()
	# Conversión de píxeles físicos de la zona segura al lienzo lógico expandido.
	var window_size: Vector2i = DisplayServer.window_get_size()
	var safe: Rect2i = DisplayServer.get_display_safe_area()
	var margin_left: float = 18.0
	var margin_right: float = 18.0
	var margin_bottom: float = 18.0
	if OS.has_feature("android") and window_size.x > 0 and window_size.y > 0:
		margin_left = maxf(margin_left, float(safe.position.x) * size.x / window_size.x)
		margin_right = maxf(margin_right, float(window_size.x-safe.end.x) * size.x / window_size.x)
		margin_bottom = maxf(margin_bottom, float(window_size.y-safe.end.y) * size.y / window_size.y)
	_radius = minf(44.0 * settings.button_scale, (size.x-margin_left-margin_right) / 11.2)
	var gap: float = _radius * 2.32
	var y: float = size.y - margin_bottom - _radius
	var left: float = margin_left + _radius
	var right: float = size.x - margin_right - _radius
	_centres = {&"move_left": Vector2(left, y), &"move_right": Vector2(left+gap, y),
		&"jump": Vector2(right, y), &"grab_throw": Vector2(right-gap, y),
		&"run": Vector2(right-gap*2.0, y)}
	if settings.left_handed:
		for action in _centres:
			_centres[action].x = size.x - _centres[action].x
	_labels[&"run"].visible = not settings.automatic_run
	if settings.automatic_run:
		_centres.erase(&"run")
	for action in _centres:
		var label: Label = _labels[action]
		label.position = _centres[action] - Vector2.ONE * _radius
		label.size = Vector2.ONE * _radius * 2.0
	queue_redraw()


func _input(event: InputEvent) -> void:
	if not visible or get_tree().paused or not is_instance_valid(input_source):
		return
	if event is InputEventScreenTouch:
		_update_pointer(event.index, event.position, event.pressed and not event.canceled)
	elif event is InputEventScreenDrag and _pointers.has(event.index):
		_update_pointer(event.index, event.position, true)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.device != InputEvent.DEVICE_ID_EMULATION:
		_update_pointer(-1, event.position, event.pressed)
	elif event is InputEventMouseMotion and _pointers.has(-1):
		_update_pointer(-1, event.position, true)


func _update_pointer(index: int, point: Vector2, down: bool) -> void:
	var previous: StringName = _pointers.get(index, &"")
	var next: StringName = &""
	if down:
		for action in _centres:
			if point.distance_to(_centres[action]) <= _radius:
				next = action
				break
	# Mantener el índice al arrastrar fuera permite volver a entrar y soltar bien.
	if down:
		_pointers[index] = next
	else:
		_pointers.erase(index)
	if not previous.is_empty():
		input_source.set_virtual_action(previous, previous in _pointers.values())
	if not next.is_empty():
		input_source.set_virtual_action(next, true)
	queue_redraw()


func release_all() -> void:
	_pointers.clear()
	if is_instance_valid(input_source):
		input_source.clear_virtual()
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		release_all()


func _draw() -> void:
	for action in _centres:
		var pressed: bool = action in _pointers.values()
		draw_circle(_centres[action], _radius, Color("276b64") if pressed else Color("142e37"))
		draw_arc(_centres[action], _radius-1.5, 0, TAU, 48,
			Color("ffdc90") if pressed else Color("d5e6df"), 3.0, true)
