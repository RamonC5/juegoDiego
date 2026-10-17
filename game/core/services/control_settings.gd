class_name ControlSettings
extends Node
## Ajustes locales separados del futuro progreso de niveles.

signal changed

const PATH: String = "user://controls.cfg"
const ACTIONS: Array[StringName] = [&"move_left", &"move_right", &"jump", &"crouch", &"grab_throw", &"run", &"pause"]
var automatic_run: bool = true
var full_jump: bool = false
var show_touch: bool = true
var left_handed: bool = false
var gesture_scale: float = 1.0
var show_gesture_hints: bool = true
var music_volume: float = 0.6
var _default_keys: Dictionary = {}


func _ready() -> void:
	for action in ACTIONS:
		_default_keys[action] = _key_codes(action)
	var config := ConfigFile.new()
	if config.load(PATH) == OK:
		automatic_run = bool(config.get_value("controls", "automatic_run", true))
		full_jump = bool(config.get_value("controls", "full_jump", false))
		show_touch = bool(config.get_value("controls", "show_touch", true))
		left_handed = bool(config.get_value("controls", "left_handed", false))
		# Migrar el ajuste de tamaño anterior sin borrar las teclas ni preferencias.
		gesture_scale = clampf(float(config.get_value("controls", "gesture_scale",
			config.get_value("controls", "button_scale", 1.0))), 0.8, 1.4)
		show_gesture_hints = bool(config.get_value("controls", "show_gesture_hints", true))
		music_volume = clampf(float(config.get_value("audio", "music_volume", 0.6)), 0.0, 1.0)
		for action in ACTIONS:
			var keys: Variant = config.get_value("keys", String(action), [])
			if keys is Array and not keys.is_empty():
				_replace_keys(action, keys)


func save() -> void:
	var config := ConfigFile.new()
	for property in ["automatic_run", "full_jump", "show_touch", "left_handed", "gesture_scale", "show_gesture_hints"]:
		config.set_value("controls", property, get(property))
	config.set_value("audio", "music_volume", music_volume)
	for action in ACTIONS:
		config.set_value("keys", String(action), _key_codes(action))
	if config.save(PATH) != OK:
		push_warning("No se pudieron guardar los ajustes de control.")
	changed.emit()


func key_label(action: StringName) -> String:
	var labels: PackedStringArray = []
	for code in _key_codes(action):
		labels.append(OS.get_keycode_string(code))
	return " / ".join(labels)


func rebind(action: StringName, code: int) -> bool:
	for other in ACTIONS:
		if other != action and code in _key_codes(other):
			return false
	_replace_keys(action, [code])
	save()
	return true


func reset_keys() -> void:
	for action in ACTIONS:
		_replace_keys(action, _default_keys[action])
	save()


func _key_codes(action: StringName) -> Array:
	var keys: Array = []
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			keys.append(int(event.physical_keycode))
	return keys


func _replace_keys(action: StringName, keys: Array) -> void:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			InputMap.action_erase_event(action, event)
	for code in keys:
		var key := InputEventKey.new()
		key.physical_keycode = code
		InputMap.action_add_event(action, key)


