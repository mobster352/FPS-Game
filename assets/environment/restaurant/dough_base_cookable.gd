extends Cookable

@export var item: Item

func can_cook(player:Player) -> bool:
	if player.item_slot.get_child_count() == 1:
		var held_item = player.item_slot.get_child(0)
		if item.in_range and held_item.has_meta("name"):
			player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.Cook, player.has_held_object())
	return item.in_range
	
func cook(player: Player) -> void:
	if player.item_slot.get_child_count() == 1:
		var held_item = player.item_slot.get_child(0)
		if held_item.has_meta("name"):
			if toppings.has(held_item.get_meta("name")):
				return
			if toppings.has("food_ingredient_pepperoni_mesh") and held_item.get_meta("name") == "food_ingredient_mushroom_mesh":
				return
			if toppings.has("food_ingredient_mushroom_mesh") and held_item.get_meta("name") == "food_ingredient_pepperoni_mesh":
				return
			if held_item.get_meta("name") == "food_ingredient_tomato_mesh":
				var tomato_sauce = preload("res://assets/kaykit/restaurant/food_ingredient_tomato_sauce.gltf").instantiate()
				update_mesh(tomato_sauce, held_item)
			elif held_item.get_meta("name") == "food_ingredient_cheese_mesh":
				var cheese = preload("res://assets/kaykit/restaurant/food_ingredient_cheese_grated.gltf").instantiate()
				update_mesh(cheese, held_item)
			elif held_item.get_meta("name") == "food_ingredient_pepperoni_mesh":
				var pepperoni = preload("res://assets/kaykit/restaurant/food_ingredient_pepperoni_slices.gltf").instantiate()
				update_mesh(pepperoni, held_item)
			elif held_item.get_meta("name") == "food_ingredient_mushroom_mesh":
				var mushrooms = preload("res://assets/kaykit/restaurant/food_ingredient_mushroom_pieces.gltf").instantiate()
				update_mesh(mushrooms, held_item)
	
func reticle_color() -> Color:
	return RETICLE_GREEN


func update_mesh(node:Node3D, held_item:Node3D) -> void:
	item.mesh.add_child(node)
	item.mesh_has_children = true
	node.global_position = item.rigid_body.global_position
	toppings.append(held_item.get_meta("name"))
	item.mesh.set_meta("toppings", toppings)
	held_item.queue_free()
