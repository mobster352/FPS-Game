extends Node3D
class_name Menu

@export var table_label: Label
@export var order_label: Label
@export var table: Table

var table_id: int
var food_id := -1

func _ready() -> void:
	GlobalSignal.add_order.connect(_add_order)
	GlobalSignal.remove_order_from_list.connect(_remove_order_from_list)
	GlobalSignal.send_table_id.connect(_send_table_id)


func _add_order(_table_id:int, _food_id:int) -> void:
	if table_id == _table_id:
		for food_item in GlobalVar.food_items:
			if food_item.food_id == _food_id:
				order_label.text = food_item.food_name
				food_id = _food_id


func _remove_order_from_list(_table_id:int) -> void:
	if table_id == _table_id:
		order_label.text = ""
		var old_food_id = food_id
		food_id = -1
		GlobalSignal.check_restaurant_food.emit(old_food_id)


func _send_table_id(_table: Table, _table_id: int) -> void:
	if table == _table:
		table_id = _table_id
		table_label.text = "Table " + str(table_id)
