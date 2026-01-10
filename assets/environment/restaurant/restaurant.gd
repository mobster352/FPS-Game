extends Node3D

@export var chair1: Chair
@export var chair2: Chair
@export var table1: Table
@export var table2: Table

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignal.table_empty.connect(_table_empty)
	GlobalSignal.get_open_table.connect(_get_open_table)


func _table_empty(_table_id:int) -> void:
	var table_1_id = table1.get_meta("table_id") as int
	var table_2_id = table2.get_meta("table_id") as int
	match _table_id:
		table_1_id:
			await get_tree().create_timer(5.0, false).timeout
			#var npc_dummy = preload("res://entities/npc/npc_dummy.tscn").instantiate() as NPC_Dummy
			#chair1.sitting_marker.add_child(npc_dummy)
			#table1.npc = npc_dummy
			#table1.dialogue_box = npc_dummy.dialogue_box
		table_2_id:
			await get_tree().create_timer(5.0, false).timeout
			#var npc_dummy = preload("res://entities/npc/npc_dummy.tscn").instantiate() as NPC_Dummy
			#chair2.sitting_marker.add_child(npc_dummy)
			#table2.npc = npc_dummy
			#table2.dialogue_box = npc_dummy.dialogue_box

func _get_open_table(npc_dummy:NPC_Dummy) -> void:
	if table1.is_empty:
		GlobalSignal.assign_customer_to_table.emit(table1,npc_dummy)
	elif table2.is_empty:
		GlobalSignal.assign_customer_to_table.emit(table2,npc_dummy)
