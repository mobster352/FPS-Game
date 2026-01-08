extends Node

enum PIZZA_TYPE {
	PEPPERONI,
	CHEESE,
	MUSHROOM
}

var food_items: Array[Food] = [
	Food.new(PIZZA_TYPE.PEPPERONI,"Pepperoni Pizza Slice"),
	Food.new(PIZZA_TYPE.CHEESE,"Cheese Pizza Slice"),
	Food.new(PIZZA_TYPE.MUSHROOM,"Mushroom Pizza Slice")
]

func get_food(food_id:int) -> Food:
	for food in food_items:
		if food.food_id == food_id:
			return food
	return null
