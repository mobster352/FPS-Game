extends Control
class_name PauseMenu

@export var timer: Timer
var can_pause := false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") and can_pause:
		hide()
		can_pause = false


func _on_visibility_changed() -> void:
	if is_node_ready():
		if visible:
			timer.start()
		elif not visible:
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
	get_tree().quit()
