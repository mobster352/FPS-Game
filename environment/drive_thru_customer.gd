extends Interactable
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


func _on_drive_thru_menu_visibility_changed() -> void:
	in_range = false
	has_order = false


func _pickup_food(food_id:int) -> void:
	if drive_thru_menu.food_id == food_id:
		pointer.show()

func _drop_food(food_id:int) -> void:
	if drive_thru_menu.food_id == food_id:
		pointer.hide()


func can_interact(player: Player) -> bool:
	if in_range:
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.Interact, player.has_held_object())
	return in_range
	
func interact(_player: Player) -> void:
	if not has_order:
		var random_food = randi_range(4,6)
		GlobalSignal.add_order.emit(0, random_food)
		GlobalSignal.check_restaurant_food.emit(random_food)
		pointer.hide()
		has_order = true
		dialogue_box.text = dialogue_box.get_order_text() + GlobalVar.get_food(random_food).food_name
		dialogue_box.show()
	
func reticle_color() -> Color:
	return RETICLE_GREEN

func interact2(player: Player) -> void:
	if player.has_held_object():
		if player.item_slot.get_child_count() > 0:
			player.drop_item()
