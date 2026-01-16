extends Interactable

@export var pizza_oven: PizzaOven

func can_interact() -> bool:
	return pizza_oven.in_range and not pizza_oven.is_locked
	
func interact(_player: Player) -> void:
	pizza_oven.open_door()
	
func reticle_color() -> Color:
	return RETICLE_GREEN
