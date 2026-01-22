extends Control
class_name PauseMenu

@export var options_menu: Control
@export var controls_menu: Control
@export var timer: Timer
@export var menu_audio: AudioStreamPlayer

var can_pause := false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") and can_pause:
		can_pause = false
		hide()


func _on_visibility_changed() -> void:
	if is_node_ready():
		if visible:
			timer.start()
		elif not visible and not can_pause:
			get_tree().paused = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_timer_timeout() -> void:
	can_pause = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_resume_pressed() -> void:
	timer.stop()
	can_pause = false
	hide()


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://assets/ui/main_menu.tscn")


func _on_options_pressed() -> void:
	hide()
	options_menu.show()


func _on_controls_pressed() -> void:
	hide()
	controls_menu.show()


func _on_texture_button_mouse_entered() -> void:
	menu_audio.play()
