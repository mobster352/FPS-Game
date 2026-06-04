extends Control


func _on_close_button_pressed() -> void:
	hide()


func _on_visibility_changed() -> void:
	if visible:
		GlobalSignal.freeze_player_camera.emit(true)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if steamworks.is_steam_active:
			steamworks.set_achievement("FINISHED_DEMO")
	else:
		GlobalSignal.freeze_player_camera.emit(false)
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
