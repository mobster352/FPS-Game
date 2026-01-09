extends Node3D
class_name DriveThruCustomer

@export var dialogue_box: DialogueBox

var in_range := false
var has_order := false


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false


func interact() -> void:
	if not has_order:
		var random_food = randi_range(0,2)
		GlobalSignal.add_order.emit(0, random_food)
		has_order = true
		dialogue_box.text = dialogue_box.get_order_text() + GlobalVar.get_food(random_food).food_name
		dialogue_box.show()


func _on_drive_thru_menu_visibility_changed() -> void:
	in_range = false
	has_order = false
