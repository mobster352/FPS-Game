extends Interactable

@export var pizza_box_stack: PizzaBoxStack

func can_interact(player: Player) -> bool:
	if pizza_box_stack.in_range:
		if player.has_held_object() and player.get_held_object().has_meta("pizzaboxes"):
			player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.CombineStack)
		elif player.has_held_object() and player.get_held_object_mesh_name() == "pizza_box_open_mesh":
			player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.PutBack, player.has_held_object())
		elif player.has_held_object():
			player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.Default, player.has_held_object())
		else:
			player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.InteractItem, player.has_held_object(), true)
	return pizza_box_stack.in_range
	
func interact(player: Player) -> void:
	pizza_box_stack.interact(player)
	
func reticle_color() -> Color:
	return RETICLE_GREEN

func interact2(player: Player) -> void:
	pizza_box_stack.interact2(player)
