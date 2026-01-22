extends Interactable

@export var item: Item

func can_interact(player: Player) -> bool:
	if item.in_range:
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.InteractItem, player.has_held_object(), player.can_place, true)
	return item.in_range
	
func interact(player: Player) -> void:
	if item.disabled:
		return
	if player.item_slot.get_child_count() > 0:
		player.drop_item()
	if get_parent():
		get_parent().remove_child(self)
	item.pickup(Vector3(deg_to_rad(10),deg_to_rad(-15),deg_to_rad(45)), Vector3(deg_to_rad(-15),deg_to_rad(0),deg_to_rad(0)))
	item.queue_free()
	
func reticle_color() -> Color:
	return RETICLE_GREEN

func interact2(player: Player) -> void:
	if player.has_held_object():
		if item.disabled:
			return
		if player.item_slot.get_child_count() > 0:
			player.drop_item()
		if get_parent():
			get_parent().remove_child(self)
