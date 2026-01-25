extends Interactable

@export var pizza_box_stack: PizzaBoxStack

func can_interact(player: Player) -> bool:
	if pizza_box_stack.in_range:
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.InteractItem, player.has_held_object(), true)
	return pizza_box_stack.in_range
	
func interact(player: Player) -> void:
	pizza_box_stack.interact(player)
	
func reticle_color() -> Color:
	return RETICLE_GREEN

func interact2(player: Player) -> void:
	pizza_box_stack.interact2(player)
