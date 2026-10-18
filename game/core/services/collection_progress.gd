class_name CollectionProgress
extends RefCounted
## Colección permanente, independiente del intento, los faroles y mejores marcas.

signal changed
signal reward_unlocked(id: String)
signal save_failed(error: Error)

var path: String
var collected: Dictionary = {}
var equipped: String = "original"
var helper_enabled: bool = true
var last_error: Error = OK
var _manifests: Dictionary = {}
var _golden: bool = false


func _init(storage_path: String = "user://collection.json") -> void:
	path = storage_path
	if not _load_file(path):
		_load_file(path + ".bak")
	if not is_unlocked(equipped):
		equipped = "original"


func _load_file(source: String) -> bool:
	if not FileAccess.file_exists(source):
		return false
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(source)) != OK:
		return false
	var data: Variant = json.data
	if not _valid_data(data):
		return false
	var valid: Dictionary = {}
	for id in data.collected:
		var entry: Variant = data.collected[id]
		if not id is String or id.is_empty() or not entry is Dictionary:
			return false
		if not entry.get("level") is String or not entry.get("kind") in ["leaf", "crystal", "fragment"]:
			return false
		valid[id] = {"level": entry.level, "kind": entry.kind}
	collected = valid
	var outfit_id: Variant = data.get("equipped", "original")
	equipped = outfit_id if outfit_id is String else "original"
	helper_enabled = data.get("helper_enabled", true) == true
	_golden = data.get("golden_forest", false) == true
	return true


func register_level(level_id: String, manifest: Dictionary) -> void:
	_manifests[level_id] = manifest.duplicate(true)


func has_item(id: String) -> bool:
	return collected.has(id)


func count(kind: String, level_id: String = "") -> int:
	var total: int = 0
	for entry in collected.values():
		if entry.kind == kind and (level_id.is_empty() or entry.level == level_id):
			total += 1
	return total


func collect_item(level_id: String, id: String, kind: String) -> bool:
	var manifest: Dictionary = _manifests.get(level_id, {})
	if collected.has(id) or manifest.get(id, "") != kind:
		return false
	var previous: Dictionary = collected.duplicate(true)
	var previous_golden: bool = _golden
	var unlocked_before: Array[String] = unlocked_outfits()
	var had_helper: bool = helper_unlocked()
	collected[id] = {"level": level_id, "kind": kind}
	if level_id == CollectionRewards.FOREST_ID and level_complete(level_id):
		_golden = true
	if not _save():
		collected = previous
		_golden = previous_golden
		save_failed.emit(last_error)
		return false
	changed.emit()
	for outfit_id in unlocked_outfits():
		if not unlocked_before.has(outfit_id):
			reward_unlocked.emit(outfit_id)
	if not had_helper and helper_unlocked():
		reward_unlocked.emit("luci")
	return true


func level_complete(level_id: String) -> bool:
	var manifest: Dictionary = _manifests.get(level_id, {})
	if manifest.is_empty():
		return false
	for id in manifest:
		if not collected.has(id):
			return false
	return true


func helper_unlocked() -> bool:
	for fragment_id in CollectionRewards.FRAGMENT_IDS:
		if not collected.has(CollectionRewards.FOREST_ID + "/fragment/" + fragment_id):
			return false
	return true


func is_unlocked(id: String) -> bool:
	for entry in CollectionRewards.OUTFITS:
		if entry.id == id:
			return _golden if id == "golden_forest" else count("leaf") >= int(entry.leaves)
	return false


func unlocked_outfits() -> Array[String]:
	var result: Array[String] = []
	for entry in CollectionRewards.OUTFITS:
		if is_unlocked(entry.id):
			result.append(entry.id)
	return result


func equip(id: String) -> bool:
	if not is_unlocked(id):
		return false
	var previous: String = equipped
	equipped = id
	if not _save():
		equipped = previous
		save_failed.emit(last_error)
		return false
	changed.emit()
	return true


func set_helper_enabled(value: bool) -> bool:
	var previous: bool = helper_enabled
	helper_enabled = value
	if not _save():
		helper_enabled = previous
		save_failed.emit(last_error)
		return false
	changed.emit()
	return true


func next_reward() -> Dictionary:
	for entry in CollectionRewards.OUTFITS:
		if int(entry.leaves) > count("leaf"):
			return entry
	return CollectionRewards.OUTFITS[-1]


func _save() -> bool:
	var temporary: String = path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		last_error = FileAccess.get_open_error()
		return false
	file.store_string(JSON.stringify({"schema_version": 1, "collected": collected,
		"equipped": equipped, "helper_enabled": helper_enabled, "golden_forest": _golden}))
	file.flush()
	last_error = file.get_error()
	file.close()
	if last_error != OK:
		return false
	# Mantener una copia válida ante una escritura incompleta o archivo corrupto.
	if FileAccess.file_exists(path) and _is_valid_save(path):
		last_error = DirAccess.copy_absolute(path, path + ".bak")
		if last_error != OK:
			return false
	last_error = DirAccess.rename_absolute(temporary, path)
	return last_error == OK


func _is_valid_save(source: String) -> bool:
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(source)) != OK:
		return false
	var data: Variant = json.data
	return _valid_data(data)


func _valid_data(data: Variant) -> bool:
	if not data is Dictionary or data.get("schema_version") != 1 or not data.get("collected") is Dictionary:
		return false
	for id in data.collected:
		var entry: Variant = data.collected[id]
		if not id is String or id.is_empty() or not entry is Dictionary:
			return false
		if not entry.get("level") is String or not entry.get("kind") in ["leaf", "crystal", "fragment"]:
			return false
	return true
