extends Interactable

@export var pizza_box: PizzaBox

func can_interact(player: Player) -> bool:
	if pizza_box.in_range:
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.InteractItem, player.has_held_object(), player.can_place)
	return pizza_box.in_range
	
func interact(_player: Player) -> void:
	pizza_box.interact()
	
func reticle_color() -> Color:
	return RETICLE_GREEN

func interact2(player: Player) -> void:
	if player.has_held_object():
		if pizza_box.disabled:
			return
		if player.item_slot.get_child_count() > 0:
			player.drop_item()
