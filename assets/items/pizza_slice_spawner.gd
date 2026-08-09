extends Node3D

@export var order_texture: TextureRect
@export var ingredients_h_box: HBoxContainer

@onready var slices: Node3D = %slices

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignal.slice_of_the_day_ready.connect(_slice_of_the_day_ready)


func _slice_of_the_day_ready() -> void:
	match GlobalVar.slice_of_the_day:
		GlobalVar.PIZZA_TYPE.PEPPERONI:
			slices.add_child(preload("uid://ccohvau3gp3bh").instantiate())
		GlobalVar.PIZZA_TYPE.CHEESE:
			slices.add_child(preload("uid://m5kwuf2m6rpm").instantiate())
		GlobalVar.PIZZA_TYPE.MUSHROOM:
			slices.add_child(preload("uid://bwkvya8vm82gh").instantiate())
	var food:Food = GlobalVar.get_food(GlobalVar.slice_of_the_day)
	order_texture.texture = load(food.cooked_texture)
	for ingredient in food.ingredients:
		var new_ingredient = preload("uid://csjrxmctsxanw").instantiate() as TextureRect
		new_ingredient.texture = load(ingredient)
		ingredients_h_box.add_child(new_ingredient)
