class_name PlayerWardrobe
extends RefCounted
## Material propio por jugador o previsualización; ninguna regla de movimiento.

const SHADER: Shader = preload("res://game/features/player/wardrobe.gdshader")


static func material_for(id: String) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = SHADER
	var outfit: Dictionary = CollectionRewards.outfit(id)
	material.set_shader_parameter("outfit", int(outfit.style))
	for part in ["scarf", "vest", "pants"]:
		material.set_shader_parameter(part + "_color", Color(outfit[part]))
	return material

