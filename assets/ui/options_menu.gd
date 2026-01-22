extends Control

@export var pause_menu: Control
@export var menu_audio: AudioStreamPlayer

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		hide()
		pause_menu.show()

func _on_window_size_button_item_selected(index: int) -> void:
	if index == 0:
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
	elif index == 1:
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED)
	elif index == 2:
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)


func _on_texture_button_pressed() -> void:
	hide()
	pause_menu.show()


func _on_show_tips_check_box_pressed() -> void:
	GlobalSignal.toggle_pointer_ui.emit()


func _on_texture_button_mouse_entered() -> void:
	menu_audio.play()


func _on_background_audio_check_box_pressed() -> void:
	GlobalSignal.toggle_background_audio.emit()
