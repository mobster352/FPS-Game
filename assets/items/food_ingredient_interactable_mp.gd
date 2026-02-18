extends InteractableMP

@export var item: Item

func can_interact(playerMP: PlayerMP) -> bool:
	if not playerMP.is_current_player():
		return false
	#if item.disabled:
		#player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.None, player.has_held_object())
	if item.in_range:
		playerMP.inputs_ui.update_actions.emit(playerMP.inputs_ui.InputAction.InteractItem, playerMP.has_held_object())
	return item.in_range
	
func interact(playerMP: PlayerMP) -> void:
	if not playerMP.is_current_player():
		return
	if item.disabled:
		return
	if playerMP.has_held_object():
		playerMP.drop_item()
	if get_parent():
		get_parent().remove_child(self)
	item.pickup(Vector3.ZERO, Vector3(deg_to_rad(10),deg_to_rad(130),deg_to_rad(0)))
	if playerMP.is_host():
		item.queue_free()
	else:
		remove_item(item.id)
	
func reticle_color() -> Color:
	return RETICLE_GREEN

func interact2(player: PlayerMP) -> void:
	if player.has_held_object():
		if item.disabled:
			return
		player.drop_item()


func remove_item(id:int) -> void:
	GlobalSignal.remove_object_from_level.emit(id)
