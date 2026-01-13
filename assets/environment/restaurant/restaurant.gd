extends Node3D
class_name Restaurant

@export var chair1: Chair
@export var chair2: Chair
@export var table1: Table
@export var table2: Table
@export var drive_thru_menu: DriveThruMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignal.table_empty.connect(_table_empty)
	GlobalSignal.get_open_table.connect(_get_open_table)
	GlobalSignal.check_restaurant_food.connect(_check_restaurant_food)

func _process(_delta: float) -> void:
	pass

func _table_empty(_table_id:int) -> void:
	pass
	#var table_1_id = table1.get_meta("table_id") as int
	#var table_2_id = table2.get_meta("table_id") as int
	#match _table_id:
		#table_1_id:
			#await get_tree().create_timer(5.0, false).timeout
			#var npc_dummy = preload("res://entities/npc/npc_dummy.tscn").instantiate() as NPC_Dummy
			#chair1.sitting_marker.add_child(npc_dummy)
			#table1.npc = npc_dummy
			#table1.dialogue_box = npc_dummy.dialogue_box
		#table_2_id:
			#await get_tree().create_timer(5.0, false).timeout
			#var npc_dummy = preload("res://entities/npc/npc_dummy.tscn").instantiate() as NPC_Dummy
			#chair2.sitting_marker.add_child(npc_dummy)
			#table2.npc = npc_dummy
			#table2.dialogue_box = npc_dummy.dialogue_box

func _get_open_table(npc_dummy:NPC_Dummy) -> void:
	if table1.is_empty:
		GlobalSignal.assign_customer_to_table.emit(table1,npc_dummy)
	elif table2.is_empty:
		GlobalSignal.assign_customer_to_table.emit(table2,npc_dummy)

func needs_food(food_id:int) -> bool:
	return table1.menu.food_id == food_id or table2.menu.food_id == food_id or drive_thru_menu.food_id == food_id

func _check_restaurant_food(food_id:int) -> void:
	GlobalSignal.toggle_pointer_by_food.emit(food_id, needs_food(food_id))
