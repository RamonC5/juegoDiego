class_name ForestStage
extends Node2D
## Construye el nivel desde sus datos y emite hechos; boot gestiona UI y progreso.

signal hint_requested(text: String)
signal counts_changed(leaves: int, crystals: int)
signal keys_changed(collected: int, required: int)
signal checkpoint_reached
signal level_completed(level_id: String, result: Dictionary)

var DEFINITION: ForestLevelDefinition = preload("res://game/data/worlds/world_01/level_01.tres")
const PROPS: Texture2D = preload("res://game/assets/textures/environments/bosque_esmeralda/forest_props_v001.png")

var player: DiegoPlayer
var leaves: int = 0
var crystals: int = 0
var total_leaves: int = 0
var defeated_enemies: int = 0
var checkpoint_active: bool = false
var active_checkpoint_index: int = -1
var completed: bool = false
var seconds: float = 0.0
var enemies: Array[ForestEnemy] = []
var collectibles: Array[ForestCollectible] = []
var level_keys: Array[LevelKey] = []
var collected_keys: Array[int] = []
var exit_door: KeyExitDoor
var bridges: Array[RootBridge] = []
var throw_targets: Array[ForestThrowTarget] = []
var pine_stations: Array[ThrowableObject] = []
var activated_mechanisms: Array[StringName] = []
var moving_platforms: Array[ForestMovingPlatform] = []
var root_gates: Array[ForestRootGate] = []
var vine_crossings: Array[ForestVineCrossing] = []
var secret_grove: ForestSecretGrove
var secret_totem: ForestSecretTotem
var _activity_seconds: float = 0.0
var _platform_hints_shown: Array[StringName] = []
var respawn_position: Vector2 = DEFINITION.spawn
var _hints_passed: Dictionary = {}
## Índices de datos estables; las instancias derrotadas pueden haberse liberado.
var _defeated_since_checkpoint: Array[int] = []
var _throw_hint_target: ForestThrowTarget
var _throw_hint_seconds: float = 0.0
var _miss_hints_shown: Array[StringName] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	respawn_position = DEFINITION.spawn
	for section in DEFINITION.ground_sections:
		_add_platform(section, true)
	for section in DEFINITION.raised_platforms:
		_add_platform(section, false)
	for section in DEFINITION.recovery_platforms:
		_add_platform(section, true)
	for x in [-40.0, DEFINITION.width + 40.0]:
		_add_platform(Rect2(x - 40, -600, 80, 2000), true, false)
	_build_scenery()
	_build_collectibles()
	_build_keys()
	_build_markers()
	_build_bridges()
	_build_root_gates()
	_build_moving_platforms()
	_build_vine_crossings()
	_build_secret()
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
	if is_instance_valid(secret_grove):
		secret_grove.hero = hero
	if is_instance_valid(secret_totem):
		secret_totem.hero = hero
	player.object_released.connect(_on_object_released)
	for crossing in vine_crossings:
		crossing.attach_player(hero)
	for index in DEFINITION.enemy_spawns.size():
		enemies.append(_spawn_enemy(index))
	_update_activity()
	if OS.has_feature("android") and OS.is_debug_build():
		var visible_art: int = 0
		for enemy in enemies:
			if enemy.has_visible_art():
				visible_art += 1
		print("SALTO_FOREST_READY level=world_01_level_01 enemies=%d art=%d" % [enemies.size(), visible_art])


func _spawn_enemy(index: int) -> ForestEnemy:
	var spec: Vector4 = DEFINITION.enemy_spawns[index]
	var enemy := ForestEnemy.new()
	enemy.spawn_index = index
	enemy.position = Vector2(spec.x, spec.y)
	enemy.patrol = Vector2(spec.z, spec.w)
	enemy.kind = DEFINITION.enemy_kinds[index]
	enemy.player = player
	_set_enemy_support(enemy, spec)
	enemy.defeated.connect(_on_enemy_defeated)
	add_child(enemy)
	return enemy


func _set_enemy_support(enemy: ForestEnemy, spec: Vector4) -> void:
	enemy.pursuit_bounds = Vector2(60.0, DEFINITION.width - 60.0)
	var margin: float = 32.0 if enemy.kind == "moflete" else 60.0
	for rect in DEFINITION.raised_platforms:
		if absf(spec.y - rect.position.y) < 2.0 and spec.x >= rect.position.x and spec.x <= rect.end.x:
			enemy.platform_guard = true
			enemy.movement_bounds = Vector2(rect.position.x + margin, rect.end.x - margin)
			enemy.patrol = Vector2(maxf(spec.z, enemy.movement_bounds.x), minf(spec.w, enemy.movement_bounds.y))
			return
	for rect in DEFINITION.ground_sections:
		if absf(spec.y - rect.position.y) < 2.0 and spec.x >= rect.position.x and spec.x <= rect.end.x:
			enemy.movement_bounds = Vector2(maxf(rect.position.x + margin, spec.x - 950.0), minf(rect.end.x - margin, spec.x + 950.0))
			return


func _build_root_gates() -> void:
	for definition in DEFINITION.root_gates:
		var gate := ForestRootGate.new()
		gate.definition = definition
		add_child(gate)
		root_gates.append(gate)
		for index in definition.stations.size():
			var station: RootBridgeDefinition = definition.stations[index]
			var target := ForestThrowTarget.new()
			target.definition = station
			target.show_connection = false
			target.activated.connect(_on_mechanism_activated)
			add_child(target)
			throw_targets.append(target)
			var pine := ThrowableObject.new()
			pine.definition = ThrowableCatalog.DEFINITIONS[2]
			pine.position = station.pine_position
			pine.respawn_delay = 4.0
			pine.recovery_bounds = station.recovery_bounds
			add_child(pine)
			pine_stations.append(pine)


func _build_bridges() -> void:
	for definition in DEFINITION.bridges:
		var bridge := RootBridge.new()
		bridge.definition = definition
		bridge.opened.connect(_on_bridge_opened)
		add_child(bridge)
		bridges.append(bridge)
		var target := ForestThrowTarget.new()
		target.definition = definition
		target.activated.connect(_on_mechanism_activated)
		add_child(target)
		throw_targets.append(target)
		var pine := ThrowableObject.new()
		pine.definition = ThrowableCatalog.DEFINITIONS[2]
		pine.position = definition.pine_position
		pine.respawn_delay = 4.0
		pine.recovery_bounds = definition.recovery_bounds
		add_child(pine)
		pine_stations.append(pine)


func _build_moving_platforms() -> void:
	for definition in DEFINITION.moving_platforms:
		var route := Line2D.new()
		route.points = PackedVector2Array([definition.start_position + Vector2(0, 38), definition.end_position + Vector2(0, 38)])
		route.width = 3.0
		route.default_color = Color("d1c39b")
		route.z_index = -3
		add_child(route)
		var platform := ForestMovingPlatform.new()
		platform.definition = definition
		add_child(platform)
		moving_platforms.append(platform)


func _build_vine_crossings() -> void:
	for origin in DEFINITION.vine_crossings:
		var crossing := ForestVineCrossing.new()
		crossing.position = origin
		crossing.fell.connect(_on_vine_fall.bind(crossing))
		add_child(crossing)
		vine_crossings.append(crossing)


func _build_secret() -> void:
	if DEFINITION.secret_grove.x < 0.0:
		return
	secret_grove = ForestSecretGrove.new()
	secret_grove.position = DEFINITION.secret_grove
	secret_grove.bonus_collected.connect(_on_secret_life_collected)
	add_child(secret_grove)
	# Tótem a la izquierda, sobre suelo firme. Es decorativo, sin colisiones.
	secret_totem = ForestSecretTotem.new()
	secret_totem.position = DEFINITION.secret_grove + Vector2(-180, 0)
	add_child(secret_totem)
	# Hojarasca densa sobre la trampilla y suelo de la cámara inferior.
	for x in [-83.0, 0.0, 83.0]:
		var bush: Sprite2D = _prop(1, DEFINITION.secret_grove + Vector2(x, 5), 89.0, 3)
		bush.modulate = Color(0.69, 0.88, 0.63, 0.90)
	for x in [11397.0, 11939.0]:
		_prop(1, Vector2(x, 1087), 116.0, 2)
	for x in [11410.0, 11475.0, 11530.0, 11680.0, 11755.0, 11835.0, 11910.0]:
		_add_collectible(Vector2(x, 1030))


func _on_secret_life_collected() -> void:
	if is_instance_valid(player) and player.gain_bonus_heart():
		hint_requested.emit("¡Brote de vida! Ahora tienes cuatro corazones de energía durante este intento.")


func _on_vine_fall(crossing: ForestVineCrossing) -> void:
	if player.dead or completed:
		return
	# La caída cuesta energía; si es mortal, boot realiza la reaparición habitual.
	player.release_vine_on_failure()
	player.take_damage(crossing.global_position + Vector2(1940, 650))
	crossing.reset_vines()
	if not player.dead:
		player.global_position = crossing.global_position + Vector2(1590, 600)
		player.velocity = Vector2.ZERO
		player.reset_physics_interpolation()
		hint_requested.emit("Salta hasta una liana móvil, balancéate y vuelve a saltar para alcanzar la siguiente.")


func _on_mechanism_activated(mechanism_id: StringName) -> void:
	if completed or activated_mechanisms.has(mechanism_id):
		return
	for bridge in bridges:
		if bridge.definition.mechanism_id == mechanism_id:
			activated_mechanisms.append(mechanism_id)
			bridge.activate()
			_throw_hint_target = null
			_throw_hint_seconds = 0.0
			hint_requested.emit("¡Diana activada! Las raíces están abriendo el paso.")
			return

	for gate in root_gates:
		for station in gate.definition.stations:
			if station.mechanism_id == mechanism_id:
				activated_mechanisms.append(mechanism_id)
				gate.activate_station(mechanism_id)
				_throw_hint_target = null
				_throw_hint_seconds = 0.0
				hint_requested.emit("¡Paso abierto! Puedes cruzar y volver cuando quieras." if gate.is_open else "¡Primera diana activada! Busca la otra marca de este tramo.")
				return


func _on_bridge_opened(mechanism_id: StringName) -> void:
	if mechanism_id == &"puente_diana_ensayo":
		hint_requested.emit("¡Puente abierto! Cruza la pasarela. La siguiente diana funciona igual.")
	else:
		hint_requested.emit("¡Puente abierto! Cruza la pasarela y continúa explorando el bosque.")


func _on_object_released() -> void:
	for target in throw_targets:
		if target.active and not _miss_hints_shown.has(target.definition.mechanism_id) \
			and absf(player.position.x - target.position.x) < 430.0:
			_throw_hint_target = target
			_throw_hint_seconds = 1.2
			return


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
	for x in range(80, int(DEFINITION.width), 1350):
		var tree: Sprite2D = _prop(0, Vector2(x, 610), 495.0, -8)
		tree.modulate = Color(0.65, 0.8, 0.7, 0.9)
	for section in DEFINITION.ground_sections:
		for x in [section.position.x + 55.0, section.end.x - 75.0]:
			_prop(1, Vector2(x, 611), 92.0, 2)
	_prop(2, DEFINITION.goal + Vector2(0, 7), 255.0, -2)
	for at in checkpoint_positions():
		_prop(3, at + Vector2(0, 6), 180.0, -2)


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


func _build_keys() -> void:
	assert(DEFINITION.key_positions.size() == KeyExitDoor.REQUIRED_KEYS, "El nivel necesita tres posiciones de llave")
	for index in DEFINITION.key_positions.size():
		var key := LevelKey.new()
		key.slot = index
		key.definition = DEFINITION.key_definition
		key.position = DEFINITION.key_positions[index]
		key.z_index = 2
		key.collected.connect(_on_key_collected)
		add_child(key)
		level_keys.append(key)


func _on_key_collected(key: LevelKey) -> void:
	if completed or not level_keys.has(key) or not key.taken or collected_keys.has(key.slot):
		return
	collected_keys.append(key.slot)
	exit_door.set_keys(collected_keys)
	keys_changed.emit(collected_keys.size(), KeyExitDoor.REQUIRED_KEYS)
	if exit_door.is_open:
		hint_requested.emit("¡Tres llaves de ramas! La puerta del bosque está abierta. Entra para completar el nivel.")
	else:
		hint_requested.emit("Llave de ramas %d recogida · %d / 3. Busca las otras llaves para abrir la puerta." % [key.slot + 1, collected_keys.size()])


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


func _build_markers() -> void:
	var positions: Array[Vector2] = checkpoint_positions()
	for index in positions.size():
		var at: Vector2 = positions[index]
		_marker(at + Vector2(0, -80), Vector2(115, 190), _on_checkpoint.bind(index))
	exit_door = KeyExitDoor.new()
	exit_door.key_definition = DEFINITION.key_definition
	exit_door.panel_texture = preload("res://game/assets/textures/keys/puerta_bosque_v001.png")
	exit_door.panel_region = Rect2(0.16894531, 0.02604167, 0.66210938, 0.93815104)
	exit_door.position = DEFINITION.goal
	exit_door.z_index = -3
	exit_door.entry_requested.connect(_on_goal)
	add_child(exit_door)


func _on_collected(collectible: ForestCollectible) -> void:
	if collectible.crystal:
		crystals += 1
		hint_requested.emit("Cristal del bosque %d / 3. ¡Sigue explorando!" % crystals)
	else:
		leaves += 1
	counts_changed.emit(leaves, crystals)


func _on_enemy_defeated(enemy: ForestEnemy, by_throw: bool) -> void:
	if _defeated_since_checkpoint.has(enemy.spawn_index):
		return
	_defeated_since_checkpoint.append(enemy.spawn_index)
	defeated_enemies += 1
	hint_requested.emit("¡Buen lanzamiento!" if by_throw else "¡Buen pisotón! Mantén el salto para llegar más alto.")


func checkpoint_positions() -> Array[Vector2]:
	if not DEFINITION.checkpoints.is_empty():
		return DEFINITION.checkpoints
	return [DEFINITION.checkpoint]


func _on_checkpoint(body: Node2D, index: int = 0) -> void:
	if body != player or player.dead or index <= active_checkpoint_index:
		return
	checkpoint_active = true
	active_checkpoint_index = index
	respawn_position = checkpoint_positions()[index] + Vector2(55, 0)
	# Las derrotas anteriores al nuevo farol quedan consolidadas en el intento.
	_defeated_since_checkpoint.clear()
	player.recover_energy()
	checkpoint_reached.emit()
	hint_requested.emit("Farol activado · Energía recuperada. Si caes, volverás aquí.")


func _on_goal(body: Node2D) -> void:
	if body != player or player.dead or completed:
		return
	if collected_keys.size() != KeyExitDoor.REQUIRED_KEYS:
		hint_requested.emit("Puerta cerrada · Llaves %d / 3. Te faltan %d para abrirla. Puedes volver a buscarlas." % [collected_keys.size(), KeyExitDoor.REQUIRED_KEYS - collected_keys.size()])
		return
	completed = true
	player.celebrate()
	level_completed.emit(DEFINITION.level_id, {
		"leaves": leaves, "crystals": crystals, "seconds": seconds,
		"enemies": defeated_enemies, "total_leaves": total_leaves,
		"keys": collected_keys.size(),
		"secret_life": is_instance_valid(secret_grove) and secret_grove.reward_taken,
	})


func respawn_player() -> void:
	# Al agotar la energía se rearma TODO el puzzle: dianas intactas,
	# puentes recogidos y barreras de dos dianas otra vez bloqueadas.
	# Se limpian las activaciones para que el mismo golpe vuelva a contar.
	for bridge in bridges:
		bridge.reset_closed()
	for gate in root_gates:
		gate.reset_closed()
	activated_mechanisms.clear()
	_throw_hint_target = null
	_throw_hint_seconds = 0.0
	for target in throw_targets:
		target.reset_to_intact()
	player.release_vine_on_failure()
	for crossing in vine_crossings:
		crossing.reset_vines()
	player.respawn(respawn_position)
	for platform in moving_platforms:
		platform.reset_cycle()
	if is_instance_valid(secret_grove):
		secret_grove.lift.reset_cycle()
	# La reaparición suelta primero cualquier objeto. Cada puesto conserva su instancia.
	for pine in pine_stations:
		pine.reset_to_spawn()
	for index in _defeated_since_checkpoint:
		# Eliminar también una animación de derrota aún pendiente, sin duplicar cuerpos.
		if is_instance_valid(enemies[index]):
			remove_child(enemies[index])
			enemies[index].queue_free()
		enemies[index] = _spawn_enemy(index)
	defeated_enemies -= _defeated_since_checkpoint.size()
	_defeated_since_checkpoint.clear()
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.active:
			enemy.reset_awareness()
	_update_activity()
	player.invulnerability = 1.5
	player.controls.block_current_physical()
	hint_requested.emit("¡Otra oportunidad! Se han cerrado los puentes y reconstruido las dianas. Conservas las llaves, hojas y cristales.")


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or player.dead or completed:
		return
	seconds += delta
	# Un pozo seguro solo existe bajo la trampilla: no cambia las caídas de otros barrancos.
	player.fall_limit_y = 1280.0 if is_instance_valid(secret_grove) and secret_grove.contains_underworld(player.global_position) else 980.0
	_activity_seconds -= delta
	if _activity_seconds <= 0.0:
		_activity_seconds = 0.25
		_update_activity()
	for platform in moving_platforms:
		if not _platform_hints_shown.has(platform.definition.platform_id) and platform.carries(player):
			_platform_hints_shown.append(platform.definition.platform_id)
			hint_requested.emit("¡El tronco te lleva! Suelta el arrastre para viajar. Salta cuando llegues a la repisa." if platform.definition.tutorial else "Deja que el tronco suba. Salta desde su borde hacia la repisa de la copa.")
	if _throw_hint_seconds > 0.0:
		_throw_hint_seconds = maxf(0.0, _throw_hint_seconds - delta)
		if is_zero_approx(_throw_hint_seconds) and is_instance_valid(_throw_hint_target) and _throw_hint_target.active:
			_miss_hints_shown.append(_throw_hint_target.definition.mechanism_id)
			hint_requested.emit("Acércate a la piña, mira hacia la diana y vuelve a lanzar. Las piñas regresan a su puesto.")
			_throw_hint_target = null
	var hints: Dictionary = {
		350: "Consigue tres llaves de ramas para abrir la salida. Salta encima de Terrón para eliminarlo; tocarlo de lado hace daño.",
		950: "Toca para coger el barril. Otro toque lo lanza en la dirección que miras.",
		1490: "Las hojas dibujan el salto sobre el hueco. Puedes caminar o correr.",
		2240: "Las tres llaves están repartidas por las tres rutas del bosque. Los cristales son opcionales. Más adelante practicarás con una piña.",
		2460: "EL PUENTE DE RAÍCES · Toca para coger la piña. Mira a la diana y toca otra vez para lanzar.",
		3330: "Activa el farol. Repite el lanzamiento a la segunda diana para abrir el puente hacia las rutas del bosque.",
		4380: "Combina saltos y pisotones. Los enemigos te perseguirán al verte, también desde las plataformas.",
		5350: "La vasija del bosque se puede recoger y lanzar. Se rompe al impactar y vuelve a su puesto.",
		5450: "TRONCOS VIAJEROS · Salta sobre el tronco y suelta el arrastre: te llevará. Si caes, vuelve a probar desde el suelo.",
		7150: "RAÍCES · DOS MARCAS: activa DIANA 1 en la repisa y DIANA 2 en el suelo. Cada una tiene su piña. Al abrir el paso podrás regresar.",
		25000: "LIANAS: salta para agarrarte a un nudo móvil. Balancea con el arrastre y vuelve a saltar hacia la siguiente.",
		6250: "El segundo tronco sube y baja. Espera abajo, sube y salta a la repisa alta. Más adelante combinarás este viaje con dianas.",
	}
	for x in hints:
		if player.position.x >= float(x) and not _hints_passed.has(x):
			_hints_passed[x] = true
			hint_requested.emit(hints[x])




func _update_activity() -> void:
	if not is_instance_valid(player):
		return
	if is_instance_valid(secret_grove):
		secret_grove.set_process(absf(secret_grove.position.x - player.position.x) < 1650.0)
	for collectible in collectibles:
		if collectible.taken:
			continue
		var nearby: bool = absf(collectible.position.x - player.position.x) < 1900.0
		if collectible.visible != nearby:
			collectible.visible = nearby
			collectible.set_process(nearby)
			collectible.set_deferred("monitoring", nearby)

