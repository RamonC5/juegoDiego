class_name CollectionRewards
extends RefCounted
## Catálogo de hitos: no gasta hojas ni cambia las capacidades físicas.

const OUTFITS: Array[Dictionary] = [
	{"id": "original", "name": "Aventurero", "leaves": 0, "description": "El equipo de siempre de Diego.", "accent": "f4c65e", "scarf": "efb62b", "vest": "32838c", "pants": "526f9e", "style": 0},
	{"id": "autumn_scarf", "name": "Pañuelo de otoño", "leaves": 12, "description": "Rojo coral intenso y tejido suave. Tu primera insignia de aventura.", "accent": "ff796f", "scarf": "ff4b48", "vest": "32838c", "pants": "526f9e", "style": 1},
	{"id": "fern_vest", "name": "Chaleco de hojas", "leaves": 45, "description": "Chaleco verde esmeralda con trama textil y pañuelo lima.", "accent": "79e5ae", "scarf": "c9ee55", "vest": "27b879", "pants": "526f9e", "style": 2},
	{"id": "forest_explorer", "name": "Explorador del bosque", "leaves": 100, "description": "Equipo azul glaciar, pañuelo turquesa y pantalón azul noche.", "accent": "73d9ff", "scarf": "30e4ce", "vest": "359fe5", "pants": "344b8f", "style": 3},
	{"id": "ladybug_hero", "name": "Traje Ladybug", "leaves": 100, "requires_fragments": true, "rarity": "ÉPICO", "description": "Traje rojo escarlata con lunares negros. Reúne 100 hojas y los tres fragmentos de luz.", "accent": "ff6478", "scarf": "ed2e43", "vest": "f22138", "pants": "d91e34", "style": 5},
	{"id": "golden_forest", "name": "Guardián dorado", "leaves": -1, "requires_complete": true, "description": "Equipo dorado con detalles marfil. Completa la colección del bosque.", "accent": "ffd77a", "scarf": "fff1b5", "vest": "efb63f", "pants": "775036", "style": 4},
	{"id": "ladybug_legend", "name": "Ladybug estelar", "leaves": -1, "requires_complete": true, "rarity": "LEGENDARIO", "description": "Traje escarlata y negro con detalles dorados. Reúne todas las hojas, cristales y fragmentos del bosque.", "accent": "ffca83", "scarf": "b9193c", "vest": "f2234e", "pants": "a81839", "style": 6},
]
const FRAGMENT_IDS: Array[String] = ["clear", "grove", "vines"]
const FOREST_ID: String = "world_01_level_01"


static func outfit(id: String) -> Dictionary:
	for entry in OUTFITS:
		if entry.id == id:
			return entry
	return OUTFITS[0]

