extends Node3D

@export var pointer: Node3D

func _ready() -> void:
	GlobalSignal.toggle_pointer.connect(_toggle_pointer)

func _on_area_3d_body_entered(body: Node3D) -> void:
	var obj = body.get_parent()
	if obj.is_in_group("items"):
		obj = obj as Item
		if body is RigidBody3D:
			body.freeze = true
		pointer.hide()
		if obj.disposable:
			if obj.name == "plate_dirty":
				obj.shrink_and_free(2, 5.0)
			else:
				obj.shrink_and_free(0)


func _toggle_pointer(meta: StringName, value: bool) -> void:
	if has_meta(meta):
		pointer.visible = value
