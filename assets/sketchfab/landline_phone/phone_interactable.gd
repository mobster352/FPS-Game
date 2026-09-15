extends Interactable

var in_range:bool = false

func can_interact(player: Player) -> bool:
	if in_range:
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.Interact)
		return true
	return false


func interact(_player: Player) -> void:
	var arr:Array = ResourceManager.get_random_pizza_delivery_quest()
	var quest:Quest = arr[0]
	#var room_number:int = arr[1]
	GlobalSignal.add_quest.emit(quest.quest_id, quest.quest_objective_id)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false
