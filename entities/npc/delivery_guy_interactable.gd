extends Interactable

@export var delivery_guy:DeliveryGuy

func can_interact(player: Player) -> bool:
	if delivery_guy.in_range:
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.Interact, player.has_held_object())
	return delivery_guy.in_range
	
func interact(player: Player) -> void:
	delivery_guy.interact(player)
