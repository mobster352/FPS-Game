extends Control

const TIMER_LIMIT = 0.25 #seconds
var timer = 0.0

func _process(delta: float) -> void:
	if visible:
		timer += delta
		if timer > TIMER_LIMIT:
			timer = 0.0
			%FPSCounter.text = str(Engine.get_frames_per_second())
	if Input.is_action_just_pressed("debug"):
		visible = not visible
