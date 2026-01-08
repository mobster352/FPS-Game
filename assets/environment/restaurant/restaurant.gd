extends Node3D

@export var chair1: Chair
@export var chair2: Chair
@export var table1: Table
@export var table2: Table

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignal.table_empty.connect(_table_empty)


func _table_empty(_table_id:int) -> void:
	var table_1_id = table1.get_meta("table_id") as int
	var table_2_id = table2.get_meta("table_id") as int
	match _table_id:
		table_1_id:
			await get_tree().create_timer(5.0, false).timeout
			var npc_dummy = preload("res://entities/npc/npc_dummy_sitting.tscn").instantiate()
			chair1.sitting_marker.add_child(npc_dummy)
		table_2_id:
			await get_tree().create_timer(5.0, false).timeout
			var npc_dummy = preload("res://entities/npc/npc_dummy_sitting.tscn").instantiate()
			chair2.sitting_marker.add_child(npc_dummy)
