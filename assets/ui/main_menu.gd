extends Control

@export var menu_audio: AudioStreamPlayer


func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://environment/level_prototype.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()



func _on_texture_button_mouse_entered() -> void:
	menu_audio.play()
