extends InteractableMP

@export var item: Item

func can_interact(player: PlayerMP) -> bool:
	#if item.disabled:
		#player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.None, player.has_held_object())
	if item.in_range:
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.InteractItem, player.has_held_object())
	return item.in_range
	
func interact(player: PlayerMP) -> void:
	if item.disabled:
		return
	if player.has_held_object():
		player.drop_item()
	if get_parent():
		get_parent().remove_child(self)
	item.pickup(Vector3.ZERO, Vector3(deg_to_rad(10),deg_to_rad(130),deg_to_rad(0)))
	if player.multiplayer.get_unique_id() == player.get_multiplayer_authority():
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
