extends Node

enum PIZZA_TYPE {
	NONE,
	PEPPERONI,
	CHEESE,
	MUSHROOM,
	PEPPERONI_PIE,
	CHEESE_PIE,
	MUSHROOM_PIE
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
		"item": "res://assets/environment/restaurant/crate_generic.tscn"
	},
	{
		"mesh": "dough_base_mesh",
		"item": "res://assets/items/food_ingredient_dough_base.tscn"
	},
	{
		"mesh": "rolling_pin_mesh",
		"item": "res://assets/items/rolling_pin.tscn"
	},
	{
		"mesh": "food_ingredient_tomato_mesh",
		"item": "res://assets/items/food_ingredient_tomato.tscn"
	},
	{
		"mesh": "food_ingredient_cheese_mesh",
		"item": "res://assets/items/food_ingredient_cheese.tscn"
	},
	{
		"mesh": "food_ingredient_mushroom_mesh",
		"item": "res://assets/items/food_ingredient_mushroom.tscn"
	},
	{
		"mesh": "food_ingredient_pepperoni_mesh",
		"item": "res://assets/items/food_ingredient_pepperoni.tscn"
	},
	{
		"mesh": "food_ingredient_pepperoni_pizza_mesh",
		"item": "res://assets/items/food_pizza_pepperoni_plated.tscn"
	},
	{
		"mesh": "food_ingredient_mushroom_pizza_mesh",
		"item": "res://assets/items/food_pizza_mushroom_plated.tscn"
	},
	{
		"mesh": "food_ingredient_cheese_pizza_mesh",
		"item": "res://assets/items/food_pizza_cheese_plated.tscn"
	},
	{
		"mesh": "pizza_box_open_mesh",
		"item": "res://assets/environment/restaurant/pizzabox_open.tscn"
	},
	{
		"mesh": "coin_a_mesh",
		"item": "res://assets/items/coin_a.tscn"
	}
]

var food_items: Array[Food] = [
	Food.new(PIZZA_TYPE.PEPPERONI,"Pepperoni Pizza Slice"),
	Food.new(PIZZA_TYPE.CHEESE,"Cheese Pizza Slice"),
	Food.new(PIZZA_TYPE.MUSHROOM,"Mushroom Pizza Slice"),
	Food.new(PIZZA_TYPE.PEPPERONI_PIE, "Pepperoni Pizza"),
	Food.new(PIZZA_TYPE.CHEESE_PIE, "Cheese Pizza"),
	Food.new(PIZZA_TYPE.MUSHROOM_PIE, "Mushroom Pizza")
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
