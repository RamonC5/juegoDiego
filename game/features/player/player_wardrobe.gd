class_name PlayerWardrobe
extends RefCounted
## Material propio por jugador o previsualización; ninguna regla de movimiento.

const SHADER: Shader = preload("res://game/features/player/wardrobe.gdshader")
const FABRIC: Texture2D = preload("res://game/assets/textures/characters/diego/wardrobe/fern_fabric_v001.png")


static func material_for(id: String) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = SHADER
	var index: int = 0
	for i in CollectionRewards.OUTFITS.size():
		if CollectionRewards.OUTFITS[i].id == id:
			index = i
	material.set_shader_parameter("outfit", index)
	material.set_shader_parameter("fern_fabric", FABRIC)
	return material
