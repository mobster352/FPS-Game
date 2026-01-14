extends Pizza

@export var pointer: Node3D

var restaurant: Restaurant

func _ready() -> void:
	GlobalSignal.drop_food.connect(_drop_food)
	GlobalSignal.pickup_food.connect(_pickup_food)
	GlobalSignal.init_restaurant.connect(_init_restaurant)
	GlobalSignal.toggle_pointer_by_food.connect(_toggle_pointer_by_food)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false


func get_slice() -> Item:
	if pizza_type == GlobalVar.PIZZA_TYPE.PEPPERONI:
		pointer.hide()
		var pizza =  preload("res://assets/items/pepperoni_slice_plate_item.tscn").instantiate() as Item
		add_child(pizza)
		return pizza
	if pizza_type == GlobalVar.PIZZA_TYPE.CHEESE:
		pointer.hide()
		var pizza =  preload("res://assets/items/cheese_slice_plate_item.tscn").instantiate() as Item
		add_child(pizza)
		return pizza
	if pizza_type == GlobalVar.PIZZA_TYPE.MUSHROOM:
		pointer.hide()
		var pizza =  preload("res://assets/items/mushroom_slice_plate_item.tscn").instantiate() as Item
		add_child(pizza)
		return pizza
	return null


func _drop_food(food_id:int) -> void:
	if pizza_type == food_id and restaurant.needs_food(food_id):
		pointer.show()


func _pickup_food(food_id:int) -> void:
	if pizza_type == food_id:
		pointer.hide()


func _init_restaurant(_restaurant:Restaurant) -> void:
	restaurant = _restaurant


func _toggle_pointer_by_food(food_id:int, value:bool) -> void:
	if pizza_type == food_id:
		pointer.visible = value
