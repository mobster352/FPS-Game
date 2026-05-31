extends Node3D
class_name DriveThruMenu

@export var car:TrafficCar

var table_id = 0
var food_id := -1

func _ready() -> void:
	GlobalSignal.add_order.connect(_add_order)
	GlobalSignal.remove_order_from_list.connect(_remove_order_from_list)
	GlobalSignal.update_drive_thru_menu.connect(_update_drive_thru_menu)

func _add_order(_table_id:int, _food_id:int) -> void:
	if table_id == _table_id:
		for food_item in GlobalVar.food_items:
			if food_item.food_id == _food_id:
				#order_label.text = food_item.food_name
				food_id = _food_id
				GlobalSignal.check_restaurant_food.emit(food_id)
				
func _remove_order_from_list(_table_id:int) -> void:
	if table_id == _table_id:
		#order_label.text = ""
		food_id = -1


func _update_drive_thru_menu(show_menu:bool, traffic_car:TrafficCar) -> void:
	car = traffic_car
	if show_menu:
		show()
	else:
		hide()
