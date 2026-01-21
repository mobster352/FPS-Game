extends Interactable

@export var computer: Computer

func can_interact(player: Player) -> bool:
	return computer.in_range
	
func interact(_player: Player) -> void:
	computer.interact(_player)
	
func reticle_color() -> Color:
	return RETICLE_GREEN
	
