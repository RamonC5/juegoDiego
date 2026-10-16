class_name ThrowableDefinition
extends Resource
## Datos compartidos por cada objeto; la entidad conserva su propio estado físico.

enum GroundBehavior { STOP, ROLL, SLIDE, BOUNCE }

@export var object_id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var texture: Texture2D
## Región del objeto en coordenadas normalizadas; independiente del tamaño de importación.
@export var art_region: Rect2 = Rect2(0, 0, 1, 1)
@export_range(20.0, 64.0) var display_width: float = 44.0
@export_range(8.0, 24.0) var collision_radius: float = 16.0
@export var launch_speed: float = 620.0
@export var launch_lift: float = 180.0
@export var gravity: float = 1200.0
@export var flight_seconds: float = 4.0
@export var ground_behavior: GroundBehavior = GroundBehavior.STOP
@export var ground_drag: float = 500.0
@export var maximum_bounces: int = 0
@export_range(0.0, 1.0) var restitution: float = 0.5
@export var spin_speed: float = 7.0
@export var break_on_impact: bool = false


func make_sprite_texture() -> AtlasTexture:
	var result := AtlasTexture.new()
	result.atlas = texture
	var pixels: Vector2 = texture.get_size()
	result.region = Rect2(art_region.position * pixels, art_region.size * pixels)
	result.filter_clip = true
	return result
