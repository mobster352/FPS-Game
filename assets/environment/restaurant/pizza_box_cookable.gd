extends Cookable

@export var pizza_box: PizzaBox

func can_cook(player:Player) -> bool:
	if pizza_box.in_range:
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.OpenLid, player.has_held_object())
	return pizza_box.in_range
	
func cook(_player: Player) -> void:
	pizza_box.cook()
	
func reticle_color() -> Color:
	return RETICLE_GREEN
