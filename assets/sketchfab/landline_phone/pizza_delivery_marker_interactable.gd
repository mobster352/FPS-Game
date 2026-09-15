extends Interactable

@export var pizza_delivery_marker:PackageMarker

var in_range:bool = false
var quest_id:StringName
var quest_objective_id:StringName
var delivery_quest:PizzaDeliveryQuest

var quest_ids:Array

func _ready() -> void:
	GlobalSignal.add_quest.connect(_add_quest)
	quest_ids.append(QuestIds.PIZZA_DELIVERY_101)


func can_interact(player: Player) -> bool:
	if in_range:
		if player.has_held_object():
			if player.get_held_object_mesh_name() == "pizza_box_open_mesh":
				player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.Interact, player.has_held_object())
				return true
	return false
	
	
func interact(player: Player) -> void:
	if not player.has_held_object():
		return
	if player.get_held_object_mesh_name() != "pizza_box_open_mesh":
		return
	if not quest_id:
		return
	
	var obj_passed:bool = false
	if delivery_quest.room_number == pizza_delivery_marker.room_number and player.get_held_object().has_meta("food_id"):
		if delivery_quest.order.food_id == player.get_held_object().get_meta("food_id"):
			obj_passed = true
	GlobalSignal.update_quest_objective.emit(quest_id, quest_objective_id, obj_passed)
	if obj_passed:
		player.get_held_object().queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false


func _add_quest(_quest_id:StringName, _quest_objective_id:StringName) -> void:
	if quest_ids.has(_quest_id):
		quest_id = _quest_id
		quest_objective_id = _quest_objective_id
		delivery_quest = ResourceManager.get_pizza_delivery_quest(quest_objective_id)
