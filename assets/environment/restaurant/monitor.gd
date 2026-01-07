extends Node3D

@export var v_box: VBoxContainer

var order_list: Array

func _ready() -> void:
	GlobalSignal.add_order.connect(_add_order)
	GlobalSignal.remove_order_from_list.connect(_remove_order_from_list)


func _add_order(table_id:int, food_id: int) -> void:
	var monitor_order = preload("res://assets/environment/restaurant/monitor_order.tscn").instantiate() as MarginContainer
	var child = monitor_order.get_child(0) as Label
	
	var food = GlobalVar.get_food(food_id) as Food
	child.text = "Table " + str(table_id) + ": " + food.food_name
	
	v_box.add_child(monitor_order)
	var order = {"table_id": table_id, "food_id": food_id, "monitor_order": monitor_order}
	order_list.append(order)

func _remove_order_from_list(table_id: int) -> void:
	var i = 0
	for order in order_list:
		if order.table_id == table_id:
			v_box.remove_child(order.monitor_order)
			order_list.remove_at(i)
		i += 1
