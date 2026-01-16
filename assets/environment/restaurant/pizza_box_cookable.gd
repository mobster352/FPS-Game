extends Cookable

@export var pizza_box: PizzaBox

func can_cook() -> bool:
	return pizza_box.in_range
	
func cook(_player: Player) -> void:
	pizza_box.cook()
	
func reticle_color() -> Color:
	return RETICLE_GREEN
