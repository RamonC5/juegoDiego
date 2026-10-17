class_name HeroTouchControls
extends Control
## Zonas amplias sin botones: arrastre horizontal, arriba/abajo y toque.
## Cada contacto conserva su función aunque cruce la mitad de la pantalla.

const NO_POINTER: int = -2
const TAP_SECONDS: float = 0.4
const GUIDE_SECONDS: float = 10.0

var input_source: PlayerInputSource
var settings: ControlSettings
var excluded_controls: Array[Control] = []
var _pointers: Dictionary = {}
var _movement_pointer: int = NO_POINTER
var _play_area: Rect2
var _travel: float = 64.0
var _dead_zone: float = 8.0
var _jump_threshold: float = 25.0
var _tap_slop: float = 18.0
var _axis: float = 0.0
var _guide_time: float = GUIDE_SECONDS
var _move_hint: Label
var _action_hint: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_PAUSABLE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_move_hint = _hint_label("←  ●  →")
	_action_hint = _hint_label("↑  ·  ↓  ·  ◉")
	_move_hint.accessibility_name = "Arrastra a izquierda o derecha para moverte"
	_action_hint.accessibility_name = "Desliza arriba para saltar, abajo para agacharte y toca para coger o lanzar"
	resized.connect(refresh)
	settings.changed.connect(refresh)
	refresh()
	# El primer ancho disponible puede ser cero: reajustar las etiquetas tras el layout.
	refresh.call_deferred()


func _hint_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color("f4f5ed"))
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0.05, 0.13, 0.16, 0.92)
	background.set_corner_radius_all(10)
	label.add_theme_stylebox_override("normal", background)
	add_child(label)
	return label


func refresh() -> void:
	if not is_instance_valid(settings):
		return
	release_all()
	visible = settings.show_touch or DisplayServer.is_touchscreen_available()
	# La zona segura física se convierte al lienzo lógico, también en tablet 4:3.
	var window_size: Vector2i = DisplayServer.window_get_size()
	var safe: Rect2i = DisplayServer.get_display_safe_area()
	var insets := Vector4(0, 0, 0, 0)
	if OS.has_feature("android") and window_size.x > 0 and window_size.y > 0:
		insets = Vector4(maxf(0, safe.position.x * size.x / window_size.x),
			maxf(0, safe.position.y * size.y / window_size.y),
			maxf(0, (window_size.x-safe.end.x) * size.x / window_size.x),
			maxf(0, (window_size.y-safe.end.y) * size.y / window_size.y))
	_play_area = Rect2(Vector2(insets.x, insets.y),
		Vector2(size.x-insets.x-insets.z, size.y-insets.y-insets.w))
	var shortest: float = minf(_play_area.size.x, _play_area.size.y)
	_travel = clampf(shortest * 0.09, 48.0, 80.0) * settings.gesture_scale
	_dead_zone = _travel * 0.12
	_jump_threshold = clampf(shortest * 0.035, 20.0, 36.0) * settings.gesture_scale
	_tap_slop = _jump_threshold * 0.7
	if is_instance_valid(_move_hint):
		var width: float = _play_area.size.x / 2.0 - 24.0
		var left := Vector2(_play_area.position.x+12, _play_area.end.y-90)
		var right := left + Vector2(_play_area.size.x/2.0, 0)
		_move_hint.position = right if settings.left_handed else left
		_action_hint.position = left if settings.left_handed else right
		_move_hint.size = Vector2(width, 76)
		_action_hint.size = Vector2(width, 76)
	_guide_time = GUIDE_SECONDS
	_update_guides()
	queue_redraw()


func _process(delta: float) -> void:
	for pointer in _pointers.values():
		pointer.age += delta
	if _guide_time > 0:
		_guide_time = maxf(0, _guide_time-delta)
		_update_guides()


func _update_guides() -> void:
	if not is_instance_valid(_move_hint):
		return
	for label in [_move_hint, _action_hint]:
		label.visible = settings.show_gesture_hints and _guide_time > 0
		label.modulate.a = minf(1, _guide_time)


func _can_read() -> bool:
	return visible and not get_tree().paused and is_instance_valid(input_source) and input_source.enabled


func _input(event: InputEvent) -> void:
	# Un contacto ya capturado se libera incluso sobre el HUD o fuera de su zona.
	if not _can_read():
		return
	var index: int = NO_POINTER
	if event is InputEventScreenTouch and _pointers.has(event.index):
		index = event.index
		if not event.pressed or event.canceled:
			_end_pointer(index, event.position, event.canceled)
	elif event is InputEventScreenDrag and _pointers.has(event.index):
		index = event.index
		_move_pointer(index, event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.device != InputEvent.DEVICE_ID_EMULATION and _pointers.has(-1):
		index = -1
		if not event.pressed:
			_end_pointer(index, event.position, false)
	elif event is InputEventMouseMotion and event.device != InputEvent.DEVICE_ID_EMULATION and _pointers.has(-1):
		index = -1
		_move_pointer(index, event.position)
	if index != NO_POINTER:
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	# Los menús reciben los nuevos contactos antes que el juego.
	if not _can_read():
		return
	var accepted: bool = false
	if event is InputEventScreenTouch and event.pressed and not event.canceled:
		accepted = _begin_pointer(event.index, event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and event.device != InputEvent.DEVICE_ID_EMULATION:
		accepted = _begin_pointer(-1, event.position)
	if accepted:
		get_viewport().set_input_as_handled()


func _begin_pointer(index: int, point: Vector2) -> bool:
	if not _play_area.has_point(point):
		return false
	for control in excluded_controls:
		if is_instance_valid(control) and control.is_visible_in_tree() and control.get_global_rect().has_point(point):
			return false
	var movement_side: bool = (point.x < _play_area.get_center().x) != settings.left_handed
	if movement_side and _movement_pointer != NO_POINTER:
		return false
	_pointers[index] = {"origin": point, "start": point, "point": point,
		"max_distance": 0.0, "age": 0.0, "mode": &"move" if movement_side else &"pending"}
	if movement_side:
		_movement_pointer = index
	queue_redraw()
	return true


func _move_pointer(index: int, point: Vector2) -> void:
	var pointer: Dictionary = _pointers[index]
	pointer.point = point
	pointer.max_distance = maxf(pointer.max_distance, point.distance_to(pointer.start))
	if pointer.mode == &"move":
		var offset: float = point.x-pointer.origin.x
		if absf(offset) > _travel:
			# El origen sigue al dedo al exceder el recorrido: invertir exige poco arrastre.
			pointer.origin.x = point.x-signf(offset)*_travel
			offset = point.x-pointer.origin.x
		_axis = signf(offset) * clampf((absf(offset)-_dead_zone)/(_travel-_dead_zone), 0, 1)
	elif pointer.mode == &"pending":
		var offset: Vector2 = point-pointer.start
		if -offset.y >= _jump_threshold and -offset.y > absf(offset.x)*0.65:
			pointer.mode = &"jump"
		elif offset.y >= _jump_threshold and offset.y > absf(offset.x)*0.65:
			pointer.mode = &"crouch"
	_sync_virtual()
	queue_redraw()


func _end_pointer(index: int, point: Vector2, canceled: bool) -> void:
	if not canceled:
		_move_pointer(index, point)
	var pointer: Dictionary = _pointers[index]
	if not canceled and pointer.mode == &"pending" and pointer.max_distance <= _tap_slop and pointer.age <= TAP_SECONDS:
		# El toque se reconoce al soltar; no dispara una acción al iniciar un salto.
		input_source.set_virtual_action(&"grab_throw", true)
		input_source.set_virtual_action(&"grab_throw", false)
	_pointers.erase(index)
	if _movement_pointer == index:
		_movement_pointer = NO_POINTER
		_axis = 0
	_sync_virtual()
	queue_redraw()


func _sync_virtual() -> void:
	input_source.set_virtual_axis(_axis)
	input_source.set_virtual_action(&"run", absf(_axis) >= 0.95)
	var jumping: bool = false
	var crouching: bool = false
	for pointer in _pointers.values():
		jumping = jumping or pointer.mode == &"jump"
		crouching = crouching or pointer.mode == &"crouch"
	input_source.set_virtual_action(&"jump", jumping)
	input_source.set_virtual_action(&"crouch", crouching)


func release_all() -> void:
	_pointers.clear()
	_movement_pointer = NO_POINTER
	_axis = 0
	if is_instance_valid(input_source):
		input_source.clear_virtual()
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		release_all()


func _draw() -> void:
	# Solo hay trazos mientras se toca; no existen objetivos fijos que acertar.
	for pointer in _pointers.values():
		var point: Vector2 = pointer.point
		if pointer.mode == &"move":
			var origin: Vector2 = pointer.origin
			draw_line(origin-Vector2(_travel, 0), origin+Vector2(_travel, 0), Color("142e37"), 14, true)
			draw_line(origin-Vector2(_travel, 0), origin+Vector2(_travel, 0), Color("d5e6df"), 2, true)
			draw_circle(origin+Vector2(clampf(point.x-origin.x, -_travel, _travel), 0), 11, Color("ffdc90"))
		elif pointer.mode == &"jump":
			draw_line(pointer.start, point, Color("ffdc90"), 4, true)
			draw_line(point+Vector2(-9, 11), point, Color("ffdc90"), 4, true)
			draw_line(point+Vector2(9, 11), point, Color("ffdc90"), 4, true)
		elif pointer.mode == &"crouch":
			draw_line(pointer.start, point, Color("ffdc90"), 4, true)
			draw_line(point+Vector2(-9, -11), point, Color("ffdc90"), 4, true)
			draw_line(point+Vector2(9, -11), point, Color("ffdc90"), 4, true)
		else:
			draw_arc(point, 14, 0, TAU, 32, Color("ffdc90"), 2, true)


