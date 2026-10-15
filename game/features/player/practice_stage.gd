extends Node2D

const PLATFORMS: Array[Rect2] = [
	Rect2(0, 500, 900, 420), Rect2(1010, 500, 570, 420),
	Rect2(1700, 500, 1200, 420), Rect2(1120, 415, 180, 24),
	Rect2(1410, 335, 160, 24), Rect2(1850, 415, 180, 24),
]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	for rectangle in PLATFORMS:
		var ground := StaticBody2D.new()
		ground.collision_layer = 1
		ground.collision_mask = 2 | 4 | 8
		var shape := CollisionShape2D.new()
		var box := RectangleShape2D.new()
		box.size = rectangle.size
		shape.shape = box
		shape.position = rectangle.get_center()
		ground.add_child(shape)
		add_child(ground)
	var boundary := StaticBody2D.new()
	boundary.collision_layer = 1
	var shape := CollisionShape2D.new()
	var wall := RectangleShape2D.new()
	wall.size = Vector2(40, 1600)
	shape.shape = wall
	shape.position = Vector2(-20, 200)
	boundary.add_child(shape)
	add_child(boundary)


func _draw() -> void:
	draw_rect(Rect2(-200, -400, 3400, 1600), Color("c7ded5"))
	for x in range(0, 3000, 320):
		draw_circle(Vector2(x+120, 495), 170, Color("b0cbc0"))
	for rectangle in PLATFORMS:
		draw_rect(rectangle, Color("365e5b"))
		draw_line(rectangle.position, rectangle.position+Vector2(rectangle.size.x, 0), Color("f7ce85"), 6.0)
