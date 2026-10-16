class_name ForestStage
extends Node2D
## Construye el nivel desde sus datos y emite hechos; boot gestiona UI y progreso.

signal hint_requested(text: String)
signal counts_changed(leaves: int, crystals: int)
signal checkpoint_reached
signal level_completed(level_id: String, result: Dictionary)

const DEFINITION: ForestLevelDefinition = preload("res://game/data/worlds/world_01/level_01.tres")
const PROPS: Texture2D = preload("res://game/assets/textures/environments/bosque_esmeralda/forest_props_v001.png")

var player: DiegoPlayer
var leaves: int = 0
var crystals: int = 0
var total_leaves: int = 0
var defeated_enemies: int = 0
var checkpoint_active: bool = false
var completed: bool = false
var seconds: float = 0.0
var enemies: Array[ForestEnemy] = []
var collectibles: Array[ForestCollectible] = []
var respawn_position: Vector2 = DEFINITION.spawn
var _hints_passed: Dictionary = {}
var _checkpoint_label: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	for section in DEFINITION.ground_sections:
		_add_platform(section, true)
	for section in DEFINITION.raised_platforms:
		_add_platform(section, false)
	for x in [-40.0, DEFINITION.width + 40.0]:
		_add_platform(Rect2(x - 40, -600, 80, 2000), true, false)
	_build_scenery()
	_build_collectibles()
	_build_markers()
	for spec in DEFINITION.object_spawns:
		var object := ThrowableObject.new()
		object.definition = ThrowableCatalog.DEFINITIONS[int(spec.z)]
		object.position = Vector2(spec.x, spec.y)
		object.respawn_delay = 4.0
		object.recovery_bounds = Rect2(-100, -400, DEFINITION.width + 200, 1500)
		add_child(object)


func start(hero: DiegoPlayer) -> void:
	player = hero
	player.fall_limit_y = 980.0
	player.position = DEFINITION.spawn
	for index in DEFINITION.enemy_spawns.size():
		var spec: Vector4 = DEFINITION.enemy_spawns[index]
		var enemy := ForestEnemy.new()
		enemy.position = Vector2(spec.x, spec.y)
		enemy.patrol = Vector2(spec.z, spec.w)
		enemy.kind = DEFINITION.enemy_kinds[index]
		enemy.player = player
		enemy.defeated.connect(_on_enemy_defeated)
		add_child(enemy)
		enemies.append(enemy)


func _add_platform(rect: Rect2, ground: bool, visible_art: bool = true) -> void:
	var platform := ForestPlatform.new()
	platform.position = rect.position
	platform.dimensions = rect.size
	platform.is_ground = ground
	platform.visible = visible_art
	platform.z_index = -1
	add_child(platform)


func _prop(index: int, at: Vector2, height: float, depth: int) -> Sprite2D:
	var sprite := Sprite2D.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = PROPS
	var size: Vector2 = PROPS.get_size()
	var left: float = 0.0 if index % 2 == 0 else 0.55
	var top: float = 0.0 if index < 2 else 0.515
	var width: float = 0.55 if index % 2 == 0 else 0.45
	var region := Rect2(size * Vector2(left, top), size * Vector2(width, 0.485 if index >= 2 else 0.515))
	atlas.region = region
	sprite.texture = atlas
	sprite.centered = false
	sprite.offset = Vector2(-region.size.x / 2.0, -region.size.y)
	sprite.scale = Vector2.ONE * height / region.size.y
	sprite.position = at
	sprite.z_index = depth
	var material := ShaderMaterial.new()
	material.shader = preload("res://game/features/player/sprite_alpha.gdshader")
	sprite.material = material
	add_child(sprite)
	return sprite


func _build_scenery() -> void:
	for x in [80.0, 1550.0, 2840.0, 4620.0, 5500.0, 6760.0, 8110.0]:
		var tree: Sprite2D = _prop(0, Vector2(x, 610), 495.0, -8)
		tree.modulate = Color(0.65, 0.8, 0.7, 0.9)
	for section in DEFINITION.ground_sections:
		for x in [section.position.x + 55.0, section.end.x - 75.0]:
			_prop(1, Vector2(x, 611), 92.0, 2)
	_prop(2, DEFINITION.goal + Vector2(0, 7), 255.0, -2)
	_prop(3, DEFINITION.checkpoint + Vector2(0, 6), 180.0, -2)


func _add_collectible(at: Vector2, crystal: bool = false) -> void:
	var collectible := ForestCollectible.new()
	collectible.position = at
	collectible.crystal = crystal
	collectible.z_index = 1
	collectible.collected.connect(_on_collected)
	add_child(collectible)
	collectibles.append(collectible)
	if not crystal:
		total_leaves += 1


func _build_collectibles() -> void:
	for section in DEFINITION.ground_sections:
		var x: float = section.position.x + 310.0
		while x < section.end.x - 140.0:
			# La meta detiene a Diego: la última hoja debe recogerse antes de su sensor.
			_add_collectible(Vector2(minf(x, DEFINITION.goal.x - 130.0), 551))
			if x >= DEFINITION.goal.x - 130.0:
				break
			x += 190.0
	for section in DEFINITION.raised_platforms:
		for offset in [65.0, 130.0, 195.0]:
			if offset < section.size.x - 20.0:
				_add_collectible(section.position + Vector2(offset, -45))
	for at in DEFINITION.crystal_positions:
		_add_collectible(at, true)
	for index in DEFINITION.ground_sections.size() - 1:
		var edge: float = DEFINITION.ground_sections[index].end.x
		for offset in [0.0, 60.0, 120.0]:
			_add_collectible(Vector2(edge + offset, 490 if offset == 60 else 525))


func _marker(at: Vector2, size: Vector2, callback: Callable) -> void:
	var area := Area2D.new()
	area.position = at
	area.collision_layer = 0
	area.collision_mask = 2
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = size
	shape.shape = rectangle
	area.add_child(shape)
	area.body_entered.connect(callback)
	add_child(area)


func _world_label(text: String, at: Vector2, width: float) -> Label:
	var label := Label.new()
	label.text = text
	label.position = at - Vector2(width / 2.0, 0)
	label.size = Vector2(width, 54)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color("fff3cb"))
	label.add_theme_color_override("font_shadow_color", Color("092b25"))
	label.add_theme_constant_override("shadow_outline_size", 5)
	add_child(label)
	return label


func _build_markers() -> void:
	_checkpoint_label = _world_label("FAROL · PUNTO DE CONTROL", DEFINITION.checkpoint + Vector2(0, -218), 360)
	_world_label("SALIDA DEL BOSQUE", DEFINITION.goal + Vector2(0, -285), 330)
	_marker(DEFINITION.checkpoint + Vector2(0, -80), Vector2(115, 190), _on_checkpoint)
	_marker(DEFINITION.goal + Vector2(0, -80), Vector2(90, 190), _on_goal)


func _on_collected(collectible: ForestCollectible) -> void:
	if collectible.crystal:
		crystals += 1
		hint_requested.emit("Cristal del bosque %d / 3. ¡Sigue explorando!" % crystals)
	else:
		leaves += 1
	counts_changed.emit(leaves, crystals)


func _on_enemy_defeated(_enemy: ForestEnemy, by_throw: bool) -> void:
	defeated_enemies += 1
	hint_requested.emit("¡Buen lanzamiento!" if by_throw else "¡Buen pisotón! Mantén el salto para llegar más alto.")


func _on_checkpoint(body: Node2D) -> void:
	if body != player or player.dead or checkpoint_active:
		return
	checkpoint_active = true
	respawn_position = DEFINITION.checkpoint + Vector2(55, 0)
	_checkpoint_label.text = "FAROL ACTIVADO · REAPARECES AQUÍ"
	checkpoint_reached.emit()
	hint_requested.emit("Punto de control activado. Si caes, volverás a este farol.")


func _on_goal(body: Node2D) -> void:
	if body != player or player.dead or completed:
		return
	completed = true
	player.celebrate()
	level_completed.emit(DEFINITION.level_id, {
		"leaves": leaves, "crystals": crystals, "seconds": seconds,
		"enemies": defeated_enemies, "total_leaves": total_leaves,
	})


func respawn_player() -> void:
	player.respawn(respawn_position)
	player.invulnerability = 1.5
	player.controls.block_current_physical()
	hint_requested.emit("¡Otra oportunidad! Las hojas y cristales recogidos se conservan en este intento.")


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or player.dead or completed:
		return
	seconds += delta
	var hints: Dictionary = {
		350: "Arrastra ← → para moverte. En la otra mitad, desliza ↑ para saltar.",
		950: "Toca para coger el barril. Otro toque lo lanza en la dirección que miras.",
		1490: "Las hojas dibujan el salto sobre el hueco. Puedes caminar o correr.",
		2240: "Las plataformas altas esconden cristales. La ruta del suelo también llega a la meta.",
		5350: "La piña del bosque también se puede recoger y lanzar.",
	}
	for x in hints:
		if player.position.x >= float(x) and not _hints_passed.has(x):
			_hints_passed[x] = true
			hint_requested.emit(hints[x])
