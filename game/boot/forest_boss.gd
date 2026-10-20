extends "res://game/boot/main.gd"
## Reutiliza pausa, controles, música, colección y guardado de la composición actual.

var _boss_bar: ProgressBar
var _boss_label: Label


func _create_stage() -> ForestStage:
	return ForestBossStage.new()


func _ready() -> void:
	super._ready()
	var arena: ForestBossStage = stage as ForestBossStage
	_keys_card.hide()
	_leaves_counter.hide()
	_crystals_counter.hide()
	_distance.hide()
	_hud_title.text = "Nudor"
	_hud_title.accessibility_name = "Nudor, el Roble Furioso. Jefe del Bosque Esmeralda"
	_boss_label = Label.new()
	_boss_label.text = "Nudor · %d / %d" % [arena.boss.health, arena.boss.maximum_health]
	_boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boss_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_boss_label.add_theme_color_override("font_color", Color("fff2c9"))
	_boss_label.add_theme_font_size_override("font_size", 24)
	_ui.add_child(_boss_label)
	_boss_bar = ProgressBar.new()
	_boss_bar.max_value = arena.boss.maximum_health
	_boss_bar.value = arena.boss.health
	_boss_bar.show_percentage = false
	_boss_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_boss_bar.accessibility_name = "Resistencia de Nudor"
	_boss_bar.accessibility_description = "Solo recibe objetos lanzados a la bellota cuando abre el pecho."
	_ui.add_child(_boss_bar)
	arena.boss.health_changed.connect(func(value: int, maximum: int):
		_boss_label.text = "Nudor · %d / %d" % [value, maximum]
		_boss_bar.value = value
		_boss_bar.accessibility_description = "%d impactos restantes de %d. Solo recibe objetos lanzados cuando abre el pecho." % [value, maximum]
	)
	_show_hint("NUDOR · Al levantar el brazo, aléjate de las raíces que marcan el manotazo. Salta sobre el barrido. Cuando abra el pecho, lanza una piña a la bellota; saltarle encima no le hace daño. Puedes lanzar en el aire. Las dos piñas se reponen.")
	# El consejo completo también se lee en el área desplazable de pausa.
	var instructions := Label.new()
	instructions.text = "CÓMO VENCER A NUDOR\nAléjate de las raíces cuando levante el brazo. Salta por encima del barrido. Cuando abra el pecho, salta y lanza una piña a la bellota. Saltarle encima no le hace daño. Las dos piñas vuelven a su puesto si las pierdes. Necesitas cinco impactos; morir reinicia el combate sin repetir las aventuras."
	instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var instructions_box: Node = _key_hint.get_parent()
	instructions_box.add_child(instructions)
	instructions_box.move_child(instructions, 0)
	_layout_hud()


func _process(delta: float) -> void:
	super._process(delta)
	# Claro completo visible en móvil: ni el aviso ni el jefe quedan fuera de cámara.
	_camera.position = Vector2(640, 360)
	_camera.zoom = Vector2.ONE * minf(1.0, get_viewport_rect().size.x / 1280.0)
	var arena: ForestBossStage = stage as ForestBossStage
	if is_instance_valid(arena.boss):
		arena.boss.visual.reduced_motion = settings.menu_reduced_motion


func _layout_hud() -> void:
	super._layout_hud()
	if is_instance_valid(_boss_bar):
		_boss_label.position = _top_panel.position + Vector2(0, 88)
		_boss_label.size = Vector2(_top_panel.size.x, 32)
		_boss_bar.position = _boss_label.position + Vector2((_boss_label.size.x - 300) / 2, 34)
		_boss_bar.size = Vector2(300, 12)


func _open_menu(title: String, allow_resume: bool = true) -> void:
	super._open_menu(title, allow_resume)
	_resume_button.text = "Reintentar contra Nudor" if player.dead else "Continuar"


func _completion_text() -> String:
	return "¡Nudor derrotado!\n¡Bosque Esmeralda completado!\n%s" % ("Resultado guardado. Puedes rejugar desde el mapa." if _result.get("saved", false) else "No se pudo guardar el resultado. Vuelve a intentarlo.")
