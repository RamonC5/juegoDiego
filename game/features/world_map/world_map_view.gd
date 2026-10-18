class_name AdventureWorldMap
extends Control
## Ilustración raster, hitos numerados y candados independientes del color.

signal world_requested(world_id: String)

const PAINTING: Texture2D = preload("res://game/assets/textures/world_map/adventure_islands_v001.webp")
var map_rect := Rect2()
var world_buttons: Array[Button] = []
var reduced_motion: bool = false
var _clock: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for index in WorldCatalog.WORLDS.size():
		var world: Dictionary = WorldCatalog.WORLDS[index]
		var unlocked: bool = not WorldCatalog.scene_for(world.id).is_empty()
		var button := Button.new()
		button.name = world.id
		button.text = "%d · %s\n%s" % [index + 1, world.name, "ENTRAR AL BOSQUE" if unlocked else "BLOQUEADO"]
		button.accessibility_name = "%s. %s" % [world.name, "Disponible, entrar al nivel uno" if unlocked else "Bloqueado, próximamente"]
		button.accessibility_description = world.detail
		button.tooltip_text = button.accessibility_name
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.add_theme_font_size_override("font_size", 19)
		button.pressed.connect(func(): world_requested.emit(world.id))
		add_child(button)
		world_buttons.append(button)
	resized.connect(_layout)
	_layout()


func _layout() -> void:
	if world_buttons.is_empty():
		return
	var available := Vector2(maxf(1, size.x - 24), maxf(1, size.y - 8))
	var factor: float = minf(available.x / PAINTING.get_width(), available.y / PAINTING.get_height())
	var painted_size := Vector2(PAINTING.get_size()) * factor
	map_rect = Rect2((size - painted_size) * 0.5, painted_size)
	var cell_size := painted_size / Vector2(4, 2)
	for index in world_buttons.size():
		var cell: Vector2i = WorldCatalog.WORLDS[index].cell
		var button: Button = world_buttons[index]
		button.size = Vector2(cell_size.x - 12, 62)
		button.position = map_rect.position + Vector2(cell) * cell_size + Vector2(6, cell_size.y - 67)
	queue_redraw()


func _process(delta: float) -> void:
	if is_visible_in_tree() and not reduced_motion:
		_clock += delta
		queue_redraw()


func _draw() -> void:
	if not map_rect.has_area():
		return
	draw_texture_rect(PAINTING, map_rect, false)
	var cell_size := map_rect.size / Vector2(4, 2)
	for index in WorldCatalog.WORLDS.size():
		var world: Dictionary = WorldCatalog.WORLDS[index]
		var cell: Vector2 = Vector2(world.cell)
		var center := map_rect.position + (cell + Vector2(0.5, 0.31)) * cell_size
		var unlocked: bool = not WorldCatalog.scene_for(world.id).is_empty()
		if unlocked:
			var pulse: float = 0.0 if reduced_motion else sin(_clock * 2.2) * 3.0
			draw_circle(center, 24 + pulse, Color(1, 0.84, 0.43, 0.2))
			draw_circle(center, 18, Color("ffe29a"))
			draw_colored_polygon(PackedVector2Array([center + Vector2(-5, -9), center + Vector2(10, 0), center + Vector2(-5, 9)]), Color("123e38"))
		else:
			# Candado dibujado como UI, con el texto BLOQUEADO en su botón.
			draw_circle(center, 24, Color(0.035, 0.12, 0.16, 0.94))
			draw_arc(center + Vector2(0, -4), 8, PI, TAU, 20, Color("e8d9ae"), 4, true)
			draw_style_box(_lock_box(), Rect2(center + Vector2(-11, -5), Vector2(22, 18)))
			draw_circle(center + Vector2(0, 2), 2.5, Color("203c42"))
			draw_line(center + Vector2(0, 3), center + Vector2(0, 7), Color("203c42"), 3, true)


func _lock_box() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("e8d9ae")
	style.set_corner_radius_all(4)
	return style
