extends Node3D
class_name OpenSign

@export var sign_text: MeshInstance3D
@export var blue_background: MeshInstance3D
@export var level: Level

var is_sign_on := false
var in_range := false


func interact() -> void:
	if not is_sign_on:
		open_store()
		level.can_advance_time = is_sign_on
		GlobalSignal.open_store.emit()
	elif level.time_of_day > 22:
		GlobalSignal.next_day.emit(false)

func open_store() -> void:
	is_sign_on = not is_sign_on
	var sign_material = sign_text.get_surface_override_material(0) as StandardMaterial3D
	var blue_material = blue_background.get_surface_override_material(0) as StandardMaterial3D
	if sign_material:
		sign_material.emission_enabled = is_sign_on
	if blue_material:
		blue_material.emission_enabled = is_sign_on


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false
