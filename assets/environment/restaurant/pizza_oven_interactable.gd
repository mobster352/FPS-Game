extends Interactable

@export var pizza_oven: PizzaOven

func can_interact(player: Player) -> bool:
	if pizza_oven.in_range and not pizza_oven.is_locked and player.has_held_object() and player.get_held_object_mesh_name() == "dough_base_mesh":
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.Interact, player.has_held_object())
	return pizza_oven.in_range and not pizza_oven.is_locked and player.has_held_object() and player.get_held_object_mesh_name() == "dough_base_mesh"
	
func interact(player: Player) -> void:
	if pizza_oven.is_open:
		if pizza_oven.has_open_pizza_slot():
			if player.has_held_object() and player.get_held_object_mesh_name() == "dough_base_mesh":
				pizza_oven.add_pizza_to_oven(player.get_held_object())
	
func reticle_color() -> Color:
	return RETICLE_GREEN

func interact2(player: Player) -> void:
	if player.has_held_object():
		player.drop_item()
