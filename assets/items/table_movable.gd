extends Movable

@export var table:Table

func can_move() -> bool:
	return table.player_in_range
	
func move() -> void:
	pass
