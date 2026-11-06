extends "res://game/boot/main.gd"

const INTRO_SCENES: Texture2D = preload("res://game/assets/textures/entrance/adventure_scenes_v001.png")


func _create_stage() -> ForestStage:
	return CoralStage.new()


func _create_backdrop() -> ForestBackdrop:
	var coast := AtlasTexture.new()
	coast.atlas = INTRO_SCENES
	var cell: Vector2 = INTRO_SCENES.get_size() / Vector2(2, 4)
	coast.region = Rect2(Vector2(cell.x, 0) + Vector2(2, 2), cell - Vector2(4, 4))
	coast.filter_clip = true
	var result := ForestBackdrop.new()
	result.background = coast
	return result


func _build_ui() -> void:
	super._build_ui()
	var guide := Label.new()
	guide.text = "LA RUTA DE LA MAREA\nLas balsas paran en ambos muelles. Salta a la cubierta y suelta el movimiento para cruzar. Reúne tres llaves en las terrazas de arena. Si ves un tótem de conchas, prueba a agacharte cerca de él."
	guide.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var guide_box: Node = _key_hint.get_parent()
	guide_box.add_child(guide)
	guide_box.move_child(guide, 0)
