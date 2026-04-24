extends Control

@export var menu_audio: AudioStreamPlayer
@export var main_menu: Control
@export var options_menu: Control

func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		get_tree().call_deferred("change_scene_to_file","uid://b10ibkxnixdiq")
	%StartGameButton.grab_focus()


func _on_exit_button_pressed() -> void:
	get_tree().quit()



func _on_texture_button_mouse_entered() -> void:
	menu_audio.play()


func _on_multiplayer_button_pressed() -> void:
	get_tree().change_scene_to_file("uid://b10ibkxnixdiq")


func _on_start_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/ui/load_game_menu.tscn")


func _on_settings_button_pressed() -> void:
	main_menu.hide()
	options_menu.show()



func _on_main_visibility_changed() -> void:
	if visible and %StartGameButton.is_inside_tree():
		%StartGameButton.grab_focus()
