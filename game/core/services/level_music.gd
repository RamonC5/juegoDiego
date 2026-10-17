class_name LevelMusic
extends AudioStreamPlayer
## Una sola voz por escena. Pausa y foco siguen al árbol del juego.


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	bus = &"Music"


func play_track(track: AudioStream) -> void:
	if stream == track and playing:
		return
	stop()
	stream = track
	if stream != null:
		play()


func set_music_volume(value: float) -> void:
	volume_db = linear_to_db(clampf(value, 0.0, 1.0)) if value > 0.0 else -80.0


func _exit_tree() -> void:
	stop()
	stream = null
