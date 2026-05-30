extends Interactable

@export var pizza_box: PizzaBox

func can_interact(player: Player) -> bool:
	if pizza_box.in_range:
		if player.get_held_object():
			if player.get_held_object().has_meta("pizzaboxes"):
				player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.CombineStack)
			else:
				player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.OpenLid, player.has_held_object())
		else:
			player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.OpenLid, player.has_held_object())
	return pizza_box.in_range
	
func interact(player: Player) -> void:
	pizza_box.interact(player)
	
func reticle_color() -> Color:
	return RETICLE_GREEN

func interact2(player: Player) -> void:
	if player.has_held_object():
		if player.get_held_object().has_meta("pizzaboxes"):
			return
		if pizza_box.disabled:
			return
		if player.item_slot.get_child_count() > 0:
			player.drop_item()
