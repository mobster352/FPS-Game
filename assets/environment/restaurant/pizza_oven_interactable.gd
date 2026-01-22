extends Interactable

@export var pizza_oven: PizzaOven

func can_interact(player: Player) -> bool:
	if pizza_oven.in_range and not pizza_oven.is_locked:
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.Interact, player.has_held_object())
	return pizza_oven.in_range and not pizza_oven.is_locked
	
func interact(_player: Player) -> void:
	pizza_oven.open_door()
	
func reticle_color() -> Color:
	return RETICLE_GREEN

func interact2(player: Player) -> void:
	if player.has_held_object():
		if player.item_slot.get_child_count() > 0:
			player.drop_item()
