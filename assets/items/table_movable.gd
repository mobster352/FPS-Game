extends Movable

@export var table:Table

const table_outline = "uid://ftktew0563fj"
const table_a2 = "uid://cx648bisbnt5"

func can_move() -> bool:
	if table.npc:
		return false
	return table.player_in_range
	
func move() -> void:
	table.placement_system.setup_object_preview.emit(table_outline, table, table_a2)
