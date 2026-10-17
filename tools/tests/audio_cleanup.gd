extends RefCounted
## Godot #76745: el mezclador libera las voces de forma asíncrona al pararlas.
## Las suites con --fixed-fps pueden terminar antes del siguiente bloque real.


static func flush(tree: SceneTree) -> void:
	_stop(tree.root)
	OS.delay_msec(120)
	for frame in 3:
		await tree.process_frame


static func _stop(node: Node) -> void:
	if node is AudioStreamPlayer:
		node.stop()
	for child in node.get_children():
		_stop(child)
