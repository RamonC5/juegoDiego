class_name EnemyVisual
extends Sprite2D
## Malla 2D sobre el raster existente. El controlador avanza el ciclo: respeta pausa,
## derrota y suspensión lejana. Cada instancia tiene material propio y comparte malla.

const MOTION_SHADER: Shader = preload("res://game/features/enemies/enemy_limb_motion.gdshader")
const GRID: int = 40
static var _meshes: Dictionary = {}

var profile: Dictionary
var pose_angles := PackedFloat32Array()
var pose_offsets := PackedVector2Array()
var phase: float = 0.0
var reduced_motion: bool = false
var _mesh: MeshInstance2D
var _motion_material: ShaderMaterial
var _gait: float = 0.0
var _breath_phase: float = 0.0
var _air_blend: float = 0.0
var _alert_blend: float = 0.0


func configure(id: String, source: Texture2D) -> void:
	profile = EnemyMotionProfiles.get_profile(id)
	var region: Rect2 = profile.region
	var source_size: Vector2 = source.get_size()
	var rect := Rect2(region.position * source_size, region.size * source_size)
	var atlas := AtlasTexture.new()
	atlas.atlas = source
	atlas.region = rect
	texture = atlas
	centered = false
	offset = Vector2(-rect.size.x / 2.0, -rect.size.y)
	# Solo se oculta el quad estático; self_modulate no afecta a los hijos.
	self_modulate.a = 0.0
	_mesh = MeshInstance2D.new()
	_mesh.name = "ArticulatedRaster"
	var key: String = source.resource_path + str(rect)
	if not _meshes.has(key):
		_meshes[key] = _build_mesh(rect, source_size)
	_mesh.mesh = _meshes[key]
	_mesh.texture = source
	_motion_material = ShaderMaterial.new()
	_motion_material.shader = MOTION_SHADER
	_mesh.material = _motion_material
	add_child(_mesh)
	var pivots := PackedVector2Array()
	var zones := PackedVector4Array()
	pose_angles.resize(8)
	pose_offsets.resize(8)
	for index in 8:
		var enabled: bool = index < profile.joints.size()
		pivots.append(profile.joints[index].pivot if enabled else Vector2.ZERO)
		zones.append(profile.joints[index].zone if enabled else Vector4(0, 0, 1, 1))
	_motion_material.set_shader_parameter("joint_count", profile.joints.size())
	_motion_material.set_shader_parameter("pivots", pivots)
	_motion_material.set_shader_parameter("zones", zones)
	_motion_material.set_shader_parameter("source_size", source_size)
	# Los perfiles usan UV locales del recorte, no del atlas completo.
	_motion_material.set_shader_parameter("region_origin", region.position)
	_motion_material.set_shader_parameter("region_extent", region.size)
	_apply_pose(false, false)


static func _build_mesh(rect: Rect2, source_size: Vector2) -> ArrayMesh:
	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	for row in GRID + 1:
		for column in GRID + 1:
			var point := Vector2(float(column) / GRID, float(row) / GRID) * rect.size
			var local := point - Vector2(rect.size.x / 2.0, rect.size.y)
			vertices.append(Vector3(local.x, local.y, 0))
			uvs.append((rect.position + point) / source_size)
	for row in GRID:
		for column in GRID:
			var a: int = row * (GRID + 1) + column
			indices.append_array(PackedInt32Array([a, a + 1, a + GRID + 1, a + 1, a + GRID + 2, a + GRID + 1]))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


func advance(delta: float, horizontal_speed: float, grounded: bool, alert: bool = false) -> void:
	var moving: float = clampf(absf(horizontal_speed) / 110.0, 0.0, 1.0) if grounded else 0.0
	_gait = move_toward(_gait, moving, delta * 3.5)
	_air_blend = move_toward(_air_blend, 0.0 if grounded else 1.0, delta * 6.0)
	_alert_blend = move_toward(_alert_blend, 1.0 if alert else 0.0, delta * 4.0)
	_breath_phase = fposmod(_breath_phase + delta * TAU * 0.38, TAU)
	# La marcha sigue la distancia real, no un metrónomo que corre al estar quieto.
	var frequency: float = absf(horizontal_speed) / float(profile.stride) if grounded else 0.0
	if profile.flying:
		frequency = float(profile.frequency)
	phase = fposmod(phase + delta * TAU * frequency, TAU)
	_apply_pose(not grounded, alert)


func face_left(left: bool) -> void:
	flip_h = left
	_mesh.scale.x = -1.0 if left else 1.0


func _support_offset(cycle: float, root: bool) -> Vector2:
	var t: float = fposmod(cycle, TAU) / TAU
	var reach: float = 0.026 if root else 0.033
	var lift: float = 0.022 if root else 0.045
	if t < 0.5:
		var u: float = t * 2.0
		# El apoyo vuelve hacia delante en arco; elevación sin esquinas en los extremos.
		return Vector2(lerpf(-reach, reach, smoothstep(0.0, 1.0, u)), -pow(sin(PI * u), 2.0) * lift)
	# Durante el apoyo el pie se mantiene plano y retrocede respecto al cuerpo.
	return Vector2(lerpf(reach, -reach, (t - 0.5) * 2.0), 0.0)


func _apply_pose(_airborne: bool, _alert: bool) -> void:
	var strength: float = 0.45 if reduced_motion else 1.0
	for index in profile.joints.size():
		var item: Dictionary = profile.joints[index]
		var cycle: float = phase + float(item.phase)
		var wave: float = sin(cycle)
		var amplitude: float = float(item.amplitude) * strength
		var activity: float = _gait
		var travel: float = 0.006
		if item.mode == "foot" or item.mode == "root":
			var support: Vector2 = _support_offset(cycle, item.mode == "root")
			pose_offsets[index] = support * activity * strength + Vector2(0, -0.012 * _air_blend * strength)
			# El pie de apoyo no gira como una hélice; solo flexiona durante el vuelo.
			pose_angles[index] = maxf(0.0, sin(cycle)) * amplitude * activity * 0.45
			continue
		if item.mode == "wing" or item.mode == "tip":
			activity = 1.0 if profile.flying else 0.30 + _gait * 0.70
			travel = 0.012 if item.mode == "tip" else 0.008
		elif item.mode == "soft":
			activity = 0.45 + _gait * 0.40
			travel = 0.010
		elif item.mode == "hand":
			# Las muñecas acompañan al brazo; no se trasladan como miembros sueltos.
			travel = 0.003
			activity = 0.12 + _gait * 0.70 + _alert_blend * 0.08
		else:
			activity = 0.08 + _gait * 0.82
		activity *= 1.0 - _air_blend * 0.55 if not profile.flying else 1.0
		pose_angles[index] = wave * amplitude * activity
		pose_offsets[index] = Vector2(wave * travel, cos(cycle) * travel * 0.20) * activity * strength
	_motion_material.set_shader_parameter("angles", pose_angles)
	_motion_material.set_shader_parameter("translations", pose_offsets)
	# Dos transferencias de peso por ciclo, respiración secundaria con raíz estable.
	position.y = -sin(phase) * 1.5 * strength if profile.flying else -pow(sin(phase), 2.0) * _gait * 1.3 * strength
	var direction: float = signf(_mesh.scale.x)
	rotation = direction * (_gait * 0.025 + _alert_blend * 0.012) * strength
	_mesh.scale.y = 1.0 + sin(_breath_phase) * 0.006 * strength
