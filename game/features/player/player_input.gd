class_name PlayerInputSource
extends Node
## Mezcla entradas físicas y táctiles sin modificar el estado global de Input.

var enabled: bool = true
var automatic_run: bool = true
var full_jump: bool = false
var _held: Dictionary = {}
var _presses: Dictionary = {}
var _blocked_physical: Dictionary = {}
var _virtual_axis: float = 0.0
var _tap_jumps: int = 0
var consumed_tap_jump: bool = false


func set_virtual_axis(value: float) -> void:
	_virtual_axis = clampf(value, -1.0, 1.0) if enabled else 0.0


func set_virtual_action(action: StringName, down: bool) -> void:
	if down and not bool(_held.get(action, false)) and enabled:
		_presses[action] = true
	_held[action] = down and enabled


func held(action: StringName) -> bool:
	return enabled and (_physical_held(action) or bool(_held.get(action, false)))


func consume(action: StringName) -> bool:
	if action == &"jump":
		consumed_tap_jump = enabled and _tap_jumps > 0
		if consumed_tap_jump:
			_tap_jumps -= 1
			return true
	var virtual_press: bool = bool(_presses.get(action, false))
	_presses.erase(action)
	var physical_press: bool = _physical_held(action) and Input.is_action_just_pressed(action)
	return enabled and (virtual_press or physical_press)


## Una pulsación táctil es un salto completo; no exige mantener ni esperar al doble toque.
## Dos contactos sucesivos entre pasos físicos conservan sus dos órdenes.
func request_tap_jump() -> void:
	if enabled:
		_tap_jumps = mini(_tap_jumps + 1, 2)


func discard_jumps() -> void:
	_tap_jumps = 0
	_presses.erase(&"jump")
	consumed_tap_jump = false


func horizontal() -> float:
	if not enabled:
		return 0.0
	var axis: float = Input.get_action_strength(&"move_right") if _physical_held(&"move_right") else 0.0
	axis -= Input.get_action_strength(&"move_left") if _physical_held(&"move_left") else 0.0
	axis += float(bool(_held.get(&"move_right", false)))
	axis -= float(bool(_held.get(&"move_left", false)))
	axis += _virtual_axis
	return clampf(axis, -1.0, 1.0)


func clear_virtual() -> void:
	discard_jumps()
	_held.clear()
	_presses.clear()
	_virtual_axis = 0.0


func block_current_physical() -> void:
	for action in [&"move_left", &"move_right", &"jump", &"crouch", &"grab_throw", &"run"]:
		if Input.is_action_pressed(action):
			_blocked_physical[action] = true


func _physical_held(action: StringName) -> bool:
	if _blocked_physical.has(action):
		if not Input.is_action_pressed(action):
			_blocked_physical.erase(action)
		return false
	return Input.is_action_pressed(action)

