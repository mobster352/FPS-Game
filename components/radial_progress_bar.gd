extends Node3D

signal radial_timeout

const TIMER_LIMIT = 30.0 #seconds
var timer = 0.0:
	set(value):
		timer = value
		%TextureProgressBar.value = timer * (100 / TIMER_LIMIT)


func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	if timer > TIMER_LIMIT:
		radial_timeout.emit()
		hide()
	timer += delta


func _on_visibility_changed() -> void:
	if visible:
		timer = 0.0
		set_process(true)
	else:
		set_process(false)
