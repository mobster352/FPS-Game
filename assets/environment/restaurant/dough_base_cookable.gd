extends Cookable

@export var item: Item

func can_cook() -> bool:
	return item.in_range
	
func cook(_player: Player) -> void:
	if item.mesh.get_child_count() > 0:
		return
	var tomato_sauce = preload("res://assets/kaykit/restaurant/food_ingredient_tomato_sauce.gltf").instantiate()
	item.mesh.add_child(tomato_sauce)
	item.mesh_has_children = true
	tomato_sauce.global_position = item.rigid_body.global_position
	
func reticle_color() -> Color:
	return RETICLE_GREEN
