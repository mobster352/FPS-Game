extends Cookable

@export var item: Item

func can_cook() -> bool:
	return item.in_range
	
func cook(player: Player) -> void:
	if player.item_slot.get_child_count() == 1:
		var held_item = player.item_slot.get_child(0)
		if held_item.has_meta("name"):
			if held_item.get_meta("name") == "rolling_pin_mesh":
				var parent = item.get_parent()
				var dough_base = preload("res://assets/items/food_ingredient_dough_base.tscn").instantiate() as Item
				parent.add_child(dough_base)
				dough_base.global_position = item.rigid_body.global_position
				item.queue_free()
	
func reticle_color() -> Color:
	return RETICLE_GREEN
