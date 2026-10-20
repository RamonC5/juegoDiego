class_name ForestBossStage
extends ForestStage
## Claro posterior a las tres aventuras: reintento local, sin farol adicional.

var boss: NudorBoss


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	respawn_position = DEFINITION.spawn
	for section in DEFINITION.ground_sections:
		_add_platform(section, true)
	for x in [-40.0, DEFINITION.width + 40.0]:
		_add_platform(Rect2(x - 40, -600, 80, 2000), true, false)
	# El mismo raster ambiental del recorrido, sin portones ni llaves de otro intento.
	for x in [90.0, 310.0, 790.0, 1200.0]:
		_prop(1, Vector2(x, 610), 120, -4)
	_prop(0, Vector2(1180, 600), 570, -5)
	for at in [Vector2(310, 574), Vector2(760, 574)]:
		var pine := ThrowableObject.new()
		pine.definition = ThrowableCatalog.DEFINITIONS[2]
		pine.position = at
		pine.respawn_delay = 3.0
		pine.recovery_bounds = Rect2(70, -200, 1130, 1050)
		add_child(pine)
		pine_stations.append(pine)
	boss = NudorBoss.new()
	boss.position = Vector2(1010, 600)
	boss.arena_left = 90.0
	boss.arena_right = 1240.0
	add_child(boss)
	boss.defeated.connect(_on_boss_defeated)
	_build_collection_rewards()


func start(hero: DiegoPlayer) -> void:
	player = hero
	player.position = respawn_position
	player.fall_limit_y = 980.0
	boss.hero = hero
	boss.begin_encounter()
	if is_instance_valid(firefly):
		firefly.hero = hero
		firefly._refresh()


func checkpoint_positions() -> Array[Vector2]:
	return []


func _physics_process(delta: float) -> void:
	if is_instance_valid(player) and not player.dead and not completed:
		seconds += delta


func respawn_player() -> void:
	player.respawn(respawn_position)
	player.controls.block_current_physical()
	player.invulnerability = 1.5
	for pine in pine_stations:
		pine.reset_to_spawn()
	boss.reset_encounter()
	boss.begin_encounter()
	hint_requested.emit("Nudor vuelve a empezar con cinco impactos. Conservas la colección y tu equipo; las dos piñas se reponen.")


func _on_boss_defeated() -> void:
	if completed:
		return
	completed = true
	player.celebrate()
	level_completed.emit(DEFINITION.level_id, {"seconds": seconds, "boss": "nudor"})
