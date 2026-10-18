class_name ForestCollectible
extends Area2D

signal collected(collectible: ForestCollectible)

@export var crystal: bool = false
var persistent_id: String = ""
var request_collection: Callable
var taken: bool = false
var _time: float = 0.0


func _ready() -> void:
	collision_layer = 32
	collision_mask = 2
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 24.0 if crystal else 18.0
	shape.shape = circle
	add_child(shape)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if taken or not body is DiegoPlayer or body.dead:
		return
	if request_collection.is_valid() and not request_collection.call(self):
		return
	mark_taken()
	collected.emit(self)


func mark_taken() -> void:
	taken = true
	set_process(false)
	set_deferred("monitoring", false)
	visible = false


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var bob := Vector2(0, sin(_time * 2.0) * 3.0)
	if crystal:
		draw_circle(bob, 30, Color(0.1, 0.9, 0.65, 0.12))
		var outline := PackedVector2Array([Vector2(0, -27), Vector2(18, -6), Vector2(12, 17), Vector2(0, 29), Vector2(-15, 12), Vector2(-18, -6)])
		for index in outline.size():
			outline[index] += bob
		draw_colored_polygon(outline, Color("2abb96"))
		draw_colored_polygon(PackedVector2Array([bob + Vector2(0, -27), bob + Vector2(-18, -6), bob + Vector2(0, 7)]), Color("c7ffe5"))
		draw_colored_polygon(PackedVector2Array([bob + Vector2(0, -27), bob + Vector2(18, -6), bob + Vector2(0, 7)]), Color("69eab2"))
		draw_colored_polygon(PackedVector2Array([bob + Vector2(18, -6), bob + Vector2(0, 29), bob + Vector2(0, 7)]), Color("14806c"))
		draw_polyline(outline + PackedVector2Array([outline[0]]), Color("e7fff0"), 2.0, true)
	else:
		draw_circle(bob, 21, Color(1.0, 0.8, 0.32, 0.10))
		var points := PackedVector2Array([Vector2(-12, 10), Vector2(-12, -3), Vector2(-5, -14), Vector2(14, -17), Vector2(14, -2), Vector2(5, 11)])
		for index in points.size():
			points[index] += bob
		draw_colored_polygon(points, Color("f4c85e"))
		draw_line(bob + Vector2(-12, 13), bob + Vector2(11, -13), Color("fff4b7"), 2.5, true)


