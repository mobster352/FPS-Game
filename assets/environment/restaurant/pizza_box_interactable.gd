extends Interactable

@export var pizza_box: PizzaBox

func can_interact() -> bool:
	return pizza_box.in_range
	
func interact(_player: Player) -> void:
	pizza_box.interact()
	
func reticle_color() -> Color:
	return RETICLE_GREEN
