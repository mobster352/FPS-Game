extends Node3D
class_name DriveThruCustomer

@export var drive_thru_menu: DriveThruMenu
@export var dialogue_box: DialogueBox
@export var pointer: Node3D

var in_range := false
var has_order := false

func _ready() -> void:
	GlobalSignal.pickup_food.connect(_pickup_food)
	GlobalSignal.drop_food.connect(_drop_food)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false


func interact() -> void:
	if not has_order:
		var random_food = randi_range(1,3)
		GlobalSignal.add_order.emit(0, random_food)
		GlobalSignal.check_restaurant_food.emit(random_food)
		pointer.hide()
		has_order = true
		dialogue_box.text = dialogue_box.get_order_text() + GlobalVar.get_food(random_food).food_name
		dialogue_box.show()


func _on_drive_thru_menu_visibility_changed() -> void:
	in_range = false
	has_order = false


func _pickup_food(food_id:int) -> void:
	if drive_thru_menu.food_id == food_id:
		pointer.show()

func _drop_food(food_id:int) -> void:
	if drive_thru_menu.food_id == food_id:
		pointer.hide()
