extends Node

var bg_music_node: AudioStreamPlayer

func _ready() -> void:
	bg_music_node = AudioStreamPlayer.new()
	bg_music_node.stream = load("res://assets/audio/Next to You.wav")
	bg_music_node.volume_db = -5.0
	bg_music_node.autoplay = true
	bg_music_node.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(bg_music_node)
