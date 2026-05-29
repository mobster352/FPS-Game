extends Node3D
class_name Table

@export var menu: Menu
@export var area_col: CollisionShape3D
@export var plate_timer: Timer
@export var chair: Chair
@export var is_empty := true
#@export var dialogue_box: DialogueBox
@export var npc: NPC_Dummy
@export var pointer: Node3D

@onready var placement_system: PlacementSystem
@onready var player: Player
@onready var reaction: Reaction = %Reaction


var player_in_range:bool

var food_item: Item
var money: int
var table_id: int

enum Tables {
	Table_Round_A,
	Table_Round_B,
	Table_Round_B_Tablecloth_Green,
	Table_Round_B_Tablecloth_Red
}

const TablesDict = {
	Tables.Table_Round_A: {
		"table_node_path": "uid://cx648bisbnt5",
		"table_outline_node_path": "uid://ftktew0563fj"
	},
	Tables.Table_Round_B: {
		"table_node_path": "uid://beal0rpet7ug6",
		"table_outline_node_path": "uid://u3r87twoyihh"
	},
	Tables.Table_Round_B_Tablecloth_Green: {
		"table_node_path": "uid://bapcem8402mk5",
		"table_outline_node_path": "uid://bnutiphxtceau"
	},
	Tables.Table_Round_B_Tablecloth_Red: {
		"table_node_path": "uid://bgef606kqnl3w",
		"table_outline_node_path": "uid://etwcw4esf47g"
	}
}

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	GlobalSignal.init_restaurant.connect(_init_restaurant)
	GlobalSignal.assign_customer_to_table.connect(_assign_customer_to_table)
	GlobalSignal.pickup_food.connect(_pickup_food)
	GlobalSignal.drop_food.connect(_drop_food)
	GlobalSignal.send_table_id.connect(_send_table_id)
	GlobalSignal.add_table.emit(self)
	placement_system = get_tree().get_first_node_in_group("placement_system")


func _init_restaurant(_restaurant: Restaurant) -> void:
	#print("init rest")
	#GlobalSignal.add_table.emit(self)
	pass


func _send_table_id(table: Table, _table_id: int) -> void:
	if table == self:
		table_id = _table_id
		set_meta("table_id", _table_id)


func _exit_tree() -> void:
	GlobalSignal.remove_table.emit(self)

func _on_area_3d_body_entered(body: Node3D) -> void:
	var obj = body.get_parent()
	if obj.is_in_group("items") and obj.has_meta("food_id") and menu.food_id != -1:
		if obj.get_meta("food_id") == menu.food_id:
			if menu.food_id in [1,2,3]:
				money = randi_range(6,10)
			elif menu.food_id in [4,5,6]:
				money = randi_range(10,15)
			else:
				money = randi_range(6,10)
			reaction.good_order = true
			GlobalSignal.add_xp.emit(10)
			player.increment_customers_satisfied()
		else:
			money = randi_range(1,3)
			reaction.good_order = false
		reaction.show()
		area_col.set_deferred("disabled", true)
		food_item = obj as Item
		food_item.disabled = true
		plate_timer.start()
		GlobalSignal.remove_order_from_list.emit(menu.table_id)
		GlobalSignal.check_restaurant_food.emit(obj.get_meta("food_id"))
		var radialProgressBar:Node3D = npc.get_node("RadialProgressBar")
		if radialProgressBar:
			radialProgressBar.hide()

func _on_plate_timer_timeout() -> void:
	var plate_dirty = load("uid://bvxmwk63a2k37").instantiate() as Item
	food_item.get_parent().add_child(plate_dirty)
	plate_dirty.global_position = food_item.rigid_body.global_position
	food_item.queue_free()
	
	var radialProgressBar:Node3D = npc.get_node("RadialProgressBar")
	if radialProgressBar:
		radialProgressBar.hide()
	
	# remove npc
	GlobalSignal.remove_customer.emit(npc)
	npc = null
	#dialogue_box = null
	GlobalSignal.table_empty.emit(table_id)
	
	area_col.set_deferred("disabled", false)
	is_empty = true
	
	player.update_money(money)
	player.increment_customers_served()


func _assign_customer_to_table(_table:Table,_npc_dummy:NPC_Dummy) -> void:
	if self == _table:
		is_empty = false


func _pickup_food(food_id:int) -> void:
	if menu.food_id and menu.food_id == food_id:
		pointer.show()


func _drop_food(food_id:int) -> void:
	if menu.food_id and menu.food_id == food_id:
		pointer.hide()


func _on_detection_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = true


func _on_detection_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
