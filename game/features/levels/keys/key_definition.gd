class_name LevelKeyDefinition
extends Resource
## Arte del entorno. Las regiones normalizadas conservan el encuadre al importar.

@export var theme_id: StringName = &"ramas"
@export var display_name: String = "Llave de ramas"
@export var material_description: String = "Ramas entrelazadas, corteza y brotes"
@export var texture: Texture2D
@export var regions: Array[Rect2] = []


func icon_for(slot: int) -> Texture2D:
	if texture == null or regions.is_empty():
		return texture
	var region: Rect2 = regions[clampi(slot, 0, regions.size() - 1)]
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(region.position * texture.get_size(), region.size * texture.get_size())
	return atlas


func sprite_material() -> ShaderMaterial:
	var result := ShaderMaterial.new()
	result.shader = preload("res://game/features/levels/keys/key_alpha.gdshader")
	return result
