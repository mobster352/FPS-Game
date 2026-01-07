extends Pizza

@onready var pepperoni_slice: Item


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false


func get_slice() -> Item:
	pepperoni_slice = preload("res://assets/items/pepperoni_slice_plate_item.tscn").instantiate()
	return pepperoni_slice
