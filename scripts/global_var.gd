extends Node

enum PIZZA_TYPE {
	NONE,
	PEPPERONI,
	CHEESE,
	MUSHROOM
}

var mesh_to_item_array: Array[Dictionary] = [
	{
		"mesh": "dough_mesh",
		"item": "res://assets/environment/restaurant/food_ingredient_dough.tscn"
	},
	{
		"mesh": "cheese_slice_plate_mesh",
		"item": "res://assets/items/cheese_slice_plate_item.tscn"
	},
	{
		"mesh": "mushroom_slice_plate_mesh",
		"item": "res://assets/items/mushroom_slice_plate_item.tscn"
	},
	{
		"mesh": "pepperoni_slice_plate_mesh",
		"item": "res://assets/items/pepperoni_slice_plate_item.tscn"
	},
	{
		"mesh": "plate_dirty_mesh",
		"item": "res://assets/items/plate_dirty.tscn"
	},
	{
		"mesh": "crate_mesh",
		"item": "res://assets/environment/restaurant/crate_dough.tscn"
	},
	{
		"mesh": "dough_base_mesh",
		"item": "res://assets/items/food_ingredient_dough_base.tscn"
	},
	{
		"mesh": "rolling_pin_mesh",
		"item": "res://assets/items/rolling_pin.tscn"
	}
]

var food_items: Array[Food] = [
	Food.new(PIZZA_TYPE.PEPPERONI,"Pepperoni Pizza Slice"),
	Food.new(PIZZA_TYPE.CHEESE,"Cheese Pizza Slice"),
	Food.new(PIZZA_TYPE.MUSHROOM,"Mushroom Pizza Slice")
]

var show_tips := true

func get_food(food_id:int) -> Food:
	for food in food_items:
		if food.food_id == food_id:
			return food
	return null

func get_item_from_mesh(mesh: StringName) -> Item:
	for mti in mesh_to_item_array:
		if mti.mesh == mesh:
			return load(mti.item).instantiate()
	return null
