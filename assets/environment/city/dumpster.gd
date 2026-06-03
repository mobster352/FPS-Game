extends Node3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	var parent = body.get_parent()
	if parent.has_meta("scene_path"):
		if parent.get_meta("scene_path") == "res://assets/environment/restaurant/crate_generic.tscn":
			GlobalSignal.add_xp.emit(5)
	if parent is Item and parent.has_meta("count"):
		parent.shrink_and_free(0, 0.25)
