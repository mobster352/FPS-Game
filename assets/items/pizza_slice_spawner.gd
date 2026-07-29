extends Node3D

@onready var slices: Node3D = %slices

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match GlobalVar.slice_of_the_day:
		GlobalVar.PIZZA_TYPE.PEPPERONI:
			slices.add_child(preload("uid://ccohvau3gp3bh").instantiate())
		GlobalVar.PIZZA_TYPE.CHEESE:
			slices.add_child(preload("uid://m5kwuf2m6rpm").instantiate())
		GlobalVar.PIZZA_TYPE.MUSHROOM:
			slices.add_child(preload("uid://bwkvya8vm82gh").instantiate())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
