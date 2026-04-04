extends Node3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	var parent = body.get_parent()
	if parent is Item:
		parent.shrink_and_free(0, 0.25)
