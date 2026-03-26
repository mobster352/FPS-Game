extends Control

func _ready() -> void:
	GlobalSignal.change_scene.connect(_change_scene)

func _on_button_pressed() -> void:
	GlobalSignal.next_day.emit(true)

func _change_scene() -> void:
	get_tree().change_scene_to_file("res://environment/level_1.tscn")
