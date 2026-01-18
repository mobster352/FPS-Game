extends Node3D

@export var pointer: CSGBox3D

const SPEED = 0.5 # Pixels per second
var direction = -1 # -1 for up, 1 for down

func _ready() -> void:
	GlobalSignal.add_order.connect(_add_order)

func _process(delta):
	#hide()
	# Move up/down
	pointer.position.y += direction * SPEED * delta
	# Reverse direction at boundaries (example for 2D)
	if pointer.position.y < 0: # If near top boundary
		direction = 1
	elif pointer.position.y > 0.5: # If near bottom boundary
		direction = -1
	
func _add_order(_table_id:int, food_id: int) -> void:
	if get_parent() is Pizza:
		var pizza = get_parent() as Pizza
		match food_id:
			GlobalVar.PIZZA_TYPE.PEPPERONI:
				if pizza.pizza_type == food_id:
					show()
			GlobalVar.PIZZA_TYPE.CHEESE:
				if pizza.pizza_type == food_id:
					show()
			GlobalVar.PIZZA_TYPE.MUSHROOM:
				if pizza.pizza_type == food_id:
					show()
