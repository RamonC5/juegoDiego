class_name EnemyVisual
extends Sprite2D
## Malla 2D sobre el raster existente. El controlador avanza el ciclo: respeta pausa,
## derrota y suspensión lejana. Cada instancia tiene material propio y comparte malla.

const MOTION_SHADER: Shader = preload("res://game/features/enemies/enemy_limb_motion.gdshader")
const GRID: int = 32
static var _meshes: Dictionary = {}

var profile: Dictionary
var pose_angles := PackedFloat32Array()
var phase: float = 0.0
var reduced_motion: bool = false
var _mesh: MeshInstance2D
var _motion_material: ShaderMaterial
var _gait: float = 0.0


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
	for index in 8:
		var enabled: bool = index < profile.joints.size()
		pivots.append(profile.joints[index].pivot if enabled else Vector2.ZERO)
		zones.append(profile.joints[index].zone if enabled else Vector4(0, 0, 1, 1))
	_motion_material.set_shader_parameter("joint_count", profile.joints.size())
	_motion_material.set_shader_parameter("pivots", pivots)
	_motion_material.set_shader_parameter("zones", zones)
	_motion_material.set_shader_parameter("source_size", source_size)
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
	var moving: float = clampf(absf(horizontal_speed) / 90.0, 0.0, 1.0) if grounded else 0.0
	_gait = move_toward(_gait, moving, delta * 5.0)
	# Fase continua al cambiar de patrulla a persecución; alas sincronizadas por ciclo.
	var frequency: float = float(profile.frequency) * (1.0 + _gait * 0.35)
	phase = fposmod(phase + delta * TAU * frequency, TAU)
	_apply_pose(not grounded, alert)


func face_left(left: bool) -> void:
	flip_h = left
	_mesh.scale.x = -1.0 if left else 1.0


func _apply_pose(airborne: bool, alert: bool) -> void:
	var strength: float = 0.45 if reduced_motion else 1.0
	for index in profile.joints.size():
		var item: Dictionary = profile.joints[index]
		var amplitude: float = float(item.amplitude) * strength
		var wave: float = sin(phase + float(item.phase))
		if item.mode == "wing" or item.mode == "tip":
			# Dos alas comparten frecuencia; puntas con retraso suave, sin rebotes bruscos.
			amplitude *= 1.0 if profile.flying else 0.55 + _gait * 0.45
		elif item.mode == "soft":
			amplitude *= 0.5 + _gait * 0.5
		else:
			amplitude *= 0.2 + _gait * 0.8
			if airborne:
				amplitude *= 0.45
			if alert and item.mode == "hand":
				amplitude *= 1.15
		pose_angles[index] = wave * amplitude
	_motion_material.set_shader_parameter("angles", pose_angles)
	# Solo presentación; nunca mover el cuerpo físico ni los sensores.
	position.y = -sin(phase) * (1.8 if profile.flying else _gait * 1.2) * strength
	rotation = sin(phase) * (0.012 if profile.flying else 0.008) * strength
