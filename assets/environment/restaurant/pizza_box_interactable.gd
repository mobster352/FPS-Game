extends Interactable

@export var pizza_box: PizzaBox

func can_interact(player: Player) -> bool:
	player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.Interact, player.has_held_object(), player.can_place)
	return pizza_box.in_range
	
func interact(_player: Player) -> void:
	pizza_box.interact()
	
func reticle_color() -> Color:
	return RETICLE_GREEN
