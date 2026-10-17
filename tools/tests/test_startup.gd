extends SceneTree
## Arranque real y cierre con tiempo para vaciar el mezclador de audio.


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var main: Node2D = load("res://game/boot/main.tscn").instantiate()
	root.add_child(main)
	for frame in 3:
		await process_frame
	await preload("res://tools/tests/audio_cleanup.gd").flush(self)
	main.queue_free()
	await process_frame
	quit()
