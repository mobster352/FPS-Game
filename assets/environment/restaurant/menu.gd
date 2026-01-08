extends Node3D
class_name Menu

@export var table_label: Label
@export var order_label: Label

@onready var table_id = get_parent().get_meta("table_id") as int
var food_id := -1

func _ready() -> void:
	table_label.text = "Table " + str(table_id)
	GlobalSignal.add_order.connect(_add_order)
	GlobalSignal.remove_order_from_list.connect(_remove_order_from_list)

func _add_order(_table_id:int, _food_id:int) -> void:
	if table_id == _table_id:
		for food_item in GlobalVar.food_items:
			if food_item.food_id == _food_id:
				order_label.text = food_item.food_name
				food_id = _food_id

func _remove_order_from_list(_table_id:int) -> void:
	if table_id == _table_id:
		order_label.text = ""
		food_id = -1
