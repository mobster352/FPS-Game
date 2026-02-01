extends Interactable

@export var npc_dummy: NPC_Dummy

func can_interact(player: Player) -> bool:
	if npc_dummy.in_range and not npc_dummy.has_order and npc_dummy.target == GlobalMarker.queue_marker:
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.Interact, player.has_held_object())
	return npc_dummy.in_range and not npc_dummy.has_order and npc_dummy.target == GlobalMarker.queue_marker
	
func interact(_player: Player) -> void:
	npc_dummy.interact()
	
func reticle_color() -> Color:
	return RETICLE_GREEN

func interact2(player: Player) -> void:
	if player.has_held_object():
		if player.item_slot.get_child_count() > 0:
			player.drop_item()
