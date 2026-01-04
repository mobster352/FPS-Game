extends Node3D

@export var door: Door

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.get_parent() is Item:
		door.count += 1
		if door.count >=  door.number_required:
			door.is_locked = false

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.get_parent() is Item:
		door.count -= 1
		if door.count <  door.number_required:
			door.is_locked = true
			door.close_door()
