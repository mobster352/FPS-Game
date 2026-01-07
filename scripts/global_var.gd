extends Node

var food_items: Array[Food] = [
	Food.new(0,"Pepperoni Pizza Slice"),
	Food.new(1,"Cheese Pizza Slice"),
	Food.new(2,"Mushroom Pizza Slice")
]

func get_food(food_id:int) -> Food:
	for food in food_items:
		if food.food_id == food_id:
			return food
	return null
