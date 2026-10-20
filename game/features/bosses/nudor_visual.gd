class_name NudorVisual
extends Node2D
## Dos poses raster con mallas y articulaciones independientes de la colisión.

const ART: Texture2D = preload("res://game/assets/textures/characters/nudor/poses_v001.png")
var closed: EnemyVisual
var opened: EnemyVisual
var _opening: float = 0.0
var _pose: float = 0.0
var reduced_motion: bool = false


func _ready() -> void:
	for id in ["nudor_closed", "nudor_open"]:
		var actor := EnemyVisual.new()
		add_child(actor)
		actor.configure(id, ART)
		# Cada celda mantiene una raíz común. El margen superior queda libre.
		actor.scale = Vector2.ONE * 0.62
		actor.position.y = 60.14
		if id == "nudor_closed":
			closed = actor
		else:
			opened = actor
	reset_pose()


func reset_pose() -> void:
	_opening = 0.0
	_pose = 0.0
	rotation = 0.0
	scale = Vector2.ONE
	modulate = Color.WHITE
	if is_instance_valid(opened):
		opened.modulate.a = 0.0
		closed.modulate.a = 1.0


func advance_pose(delta: float, state: int, elapsed: float, warning: float) -> void:
	var exposing: bool = state in [NudorBoss.State.OPEN, NudorBoss.State.HURT, NudorBoss.State.DEFEATED]
	_opening = move_toward(_opening, 1.0 if exposing else 0.0, delta * 5.0)
	opened.modulate.a = _opening
	closed.modulate.a = 1.0 - _opening
	var target: float = 0.0
	if state in [NudorBoss.State.SLAM_WARNING, NudorBoss.State.SWEEP_WARNING]:
		target = smoothstep(0.0, warning, elapsed)
	elif state in [NudorBoss.State.SLAM, NudorBoss.State.SWEEP]:
		target = -0.55
	_pose = move_toward(_pose, target, delta * 3.5)
	for actor in [closed, opened]:
		actor.reduced_motion = reduced_motion
		actor.advance(delta, 0.0, true, target != 0.0)
		var angles: PackedFloat32Array = actor.pose_angles.duplicate()
		# Hombros y muñecas tienen amplitudes distintas; las raíces respiran.
		angles[0] += _pose * 0.42
		angles[1] -= _pose * 0.20
		angles[2] -= _pose * 0.35
		angles[3] += _pose * 0.17
		actor._motion_material.set_shader_parameter("angles", angles)
		actor.position.y += 60.14
	if state == NudorBoss.State.HURT:
		rotation = sin(minf(elapsed, 1.0) * PI) * 0.045
	elif state == NudorBoss.State.DEFEATED:
		scale.y = move_toward(scale.y, 0.68, delta * 0.4)
		rotation = move_toward(rotation, -0.08, delta * 0.15)
	else:
		rotation = move_toward(rotation, 0.0, delta)
