class_name TableMovable
extends Movable

@export var table:Table
@export var table_type:Table.Tables

func can_move() -> bool:
	if table.npc:
		return false
	return table.player_in_range
	
func move() -> void:
	table.placement_system.setup_object_preview.emit(
		Table.TablesDict.get(table_type).get("table_outline_node_path"), 
		table, 
		Table.TablesDict.get(table_type).get("table_node_path"), 
		0
	)

func sell() -> void:
	table.placement_system.sell_table(table)
