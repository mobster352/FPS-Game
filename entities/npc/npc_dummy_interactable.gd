extends Interactable

@export var npc_dummy: NPC_Dummy

func can_interact() -> bool:
	return npc_dummy.in_range and not npc_dummy.has_order
	
func interact(_player: Player) -> void:
	npc_dummy.interact()
	
func reticle_color() -> Color:
	return RETICLE_GREEN
