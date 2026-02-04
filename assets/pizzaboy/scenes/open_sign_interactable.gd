extends Interactable

@export var open_sign:OpenSign

func can_interact(player: Player) -> bool:
	if open_sign.in_range:
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.Interact)
	return open_sign.in_range
	
func interact(_player: Player) -> void:
	open_sign.interact()
	
func reticle_color() -> Color:
	return RETICLE_WHITE
