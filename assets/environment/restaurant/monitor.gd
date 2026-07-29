extends Node3D

@export var grid_container: GridContainer

const monitor_order_table = preload("uid://c06pjdmf0upgb")
const monitor_order_cooked = preload("uid://3qqp6fwhrt1p")
const monitor_order_ingredients = preload("uid://spry8ppndki4")
const monitor_ingredient = preload("uid://csjrxmctsxanw")

var order_list: Array

func _ready() -> void:
	GlobalSignal.add_order.connect(_add_order)
	GlobalSignal.remove_order_from_list.connect(_remove_order_from_list)


func _add_order(table_id:int, food_id: int) -> void:
	var monitor_order_table_instance = monitor_order_table.instantiate() as Control
	var label:Label = monitor_order_table_instance.get_child(0) as Label
	
	var monitor_order_cooked_instance = monitor_order_cooked.instantiate() as Control
	var cooked_texture:TextureRect = monitor_order_cooked_instance.get_child(0) as TextureRect
	
	var monitor_order_ingredients_instance = monitor_order_ingredients.instantiate() as Control
	var hbox:HBoxContainer = monitor_order_ingredients_instance.get_child(0) as HBoxContainer
	
	var food = GlobalVar.get_food(food_id) as Food
	if table_id == 0:
		label.text = "Drive-Thru"
		cooked_texture.texture = load(food.cooked_texture)
		for ingredient in food.ingredients:
			var new_ingredient = monitor_ingredient.instantiate() as TextureRect
			new_ingredient.texture = load(ingredient)
			hbox.add_child(new_ingredient)
	else:
		label.text = str(table_id)
		cooked_texture.texture = load(food.cooked_texture)
		for ingredient in food.ingredients:
			var new_ingredient = monitor_ingredient.instantiate() as TextureRect
			new_ingredient.texture = load(ingredient)
			hbox.add_child(new_ingredient)
	
	grid_container.add_child(monitor_order_table_instance)
	grid_container.add_child(monitor_order_cooked_instance)
	grid_container.add_child(monitor_order_ingredients_instance)
	var order = {"table_id": table_id, "food_id": food_id, "monitor_order_table": monitor_order_table_instance, "monitor_order_cooked": monitor_order_cooked_instance, "monitor_order_ingredients": monitor_order_ingredients_instance}
	order_list.append(order)

func _remove_order_from_list(table_id: int) -> void:
	var i = 0
	for order in order_list:
		if order.table_id == table_id:
			grid_container.remove_child(order.monitor_order_table)
			grid_container.remove_child(order.monitor_order_cooked)
			grid_container.remove_child(order.monitor_order_ingredients)
			order_list.remove_at(i)
		i += 1
