class_name LevelProgress
extends RefCounted
## Resultados locales versionados. Rejugar siempre conserva los mejores valores.

var path: String = "user://progress.json"
var levels: Dictionary = {}


func _init(storage_path: String = "user://progress.json") -> void:
	path = storage_path
	if not FileAccess.file_exists(path):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed is Dictionary and parsed.get("schema_version") == 1 and parsed.get("levels") is Dictionary:
		levels = parsed["levels"]


func is_completed(level_id: String) -> bool:
	var record: Variant = levels.get(level_id, {})
	return record is Dictionary and record.get("completed", false) == true


func record_completion(level_id: String, result: Dictionary) -> Error:
	var previous: Dictionary = levels.get(level_id, {})
	var record: Dictionary = {
		"unlocked": true, "completed": true,
		"completions": int(previous.get("completions", 0)) + 1,
		"best_leaves": maxi(int(previous.get("best_leaves", 0)), int(result.get("leaves", 0))),
		"best_crystals": maxi(int(previous.get("best_crystals", 0)), int(result.get("crystals", 0))),
		"best_keys": maxi(int(previous.get("best_keys", 0)), int(result.get("keys", 0))),
		"best_seconds": minf(float(previous.get("best_seconds", INF)), float(result.get("seconds", 0.0))),
	}
	var updated: Dictionary = levels.duplicate(true)
	updated[level_id] = record
	var temporary: String = path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify({"schema_version": 1, "levels": updated}, "\t"))
	file.flush()
	var write_error: Error = file.get_error()
	file.close()
	if write_error != OK:
		return write_error
	var error: Error = DirAccess.rename_absolute(temporary, path)
	if error == OK:
		levels = updated
	return error

