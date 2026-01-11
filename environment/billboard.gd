extends Node3D
class_name Billboard

@export var billboard_ui: Control

var in_range := false


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false


func show_billboard_ui() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	billboard_ui.show()
