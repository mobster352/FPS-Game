extends Node3D



func _on_area_3d_body_entered(body: Node3D) -> void:
	var obj = body.get_parent()
	if obj.is_in_group("items"):
		obj = obj as Item
		if obj.disposable:
			obj.shrink_and_free()
