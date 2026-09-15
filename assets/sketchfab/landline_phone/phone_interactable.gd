extends Interactable

@export var landline_phone:LandlinePhone
@onready var dialogue_box: DialogueBox = %DialogueBox

var in_range:bool = false
var current_quest:Quest

const FOOD_DIALOGUE_NAMES := {
	4: "PEPPERONI",
	5: "CHEESE",
	6: "MUSHROOM"
}

func can_interact(player: Player) -> bool:
	if in_range:
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.Interact)
		return true
	return false


func interact(_player: Player) -> void:
	if not landline_phone.is_ringing:
		return
	var arr:Array = ResourceManager.get_random_pizza_delivery_quest()
	var quest:Quest = arr[0]
	var room_number:int = arr[1]
	var order:Food = arr[2]
	current_quest = quest
	
	var dialogue_id:StringName = get_dialogue_id_from_order(room_number, order.food_id)
	
	if dialogue_id:
		dialogue_box.dialogue_id = dialogue_id
		dialogue_box.show()


func get_dialogue_id_from_order(room_number:int, food_id:int) -> StringName:
	var food_name: String = FOOD_DIALOGUE_NAMES.get(food_id, "")
	if food_name.is_empty():
		return &""
	return StringName("PIZZA_DELIVERY_%d_%s" % [room_number, food_name])


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false


func _on_dialogue_box_end_dialogue(_npc: Node3D) -> void:
	GlobalSignal.add_quest.emit(current_quest.quest_id, current_quest.quest_objective_id)
	landline_phone.set_ringing(false)
