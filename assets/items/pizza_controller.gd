extends Pizza

@export var pizza_type: GlobalVar.PIZZA_TYPE

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false


func get_slice() -> Item:
	if pizza_type == GlobalVar.PIZZA_TYPE.PEPPERONI:
		return preload("res://assets/items/pepperoni_slice_plate_item.tscn").instantiate() as Item
	if pizza_type == GlobalVar.PIZZA_TYPE.CHEESE:
		return preload("res://assets/items/cheese_slice_plate_item.tscn").instantiate() as Item
	if pizza_type == GlobalVar.PIZZA_TYPE.MUSHROOM:
		return preload("res://assets/items/mushroom_slice_plate_item.tscn").instantiate() as Item
	return null
