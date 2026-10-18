class_name CollectionRewards
extends RefCounted
## Catálogo de hitos: no gasta hojas ni cambia las capacidades físicas.

const OUTFITS: Array[Dictionary] = [
	{"id": "original", "name": "Aventurero", "leaves": 0, "description": "El equipo de siempre de Diego."},
	{"id": "autumn_scarf", "name": "Pañuelo de otoño", "leaves": 12, "description": "Un pañuelo rojo para tus primeras aventuras."},
	{"id": "fern_vest", "name": "Chaleco de hojas", "leaves": 45, "description": "Un chaleco tejido con helechos del bosque."},
	{"id": "forest_explorer", "name": "Explorador del bosque", "leaves": 100, "description": "Chaleco de helechos, pañuelo verde y pantalón de explorador."},
	{"id": "golden_forest", "name": "Guardián dorado", "leaves": -1, "description": "Todas las hojas, cristales y fragmentos del Bosque Esmeralda."},
]
const FRAGMENT_IDS: Array[String] = ["clear", "grove", "vines"]
const FOREST_ID: String = "world_01_level_01"


static func outfit(id: String) -> Dictionary:
	for entry in OUTFITS:
		if entry.id == id:
			return entry
	return OUTFITS[0]
