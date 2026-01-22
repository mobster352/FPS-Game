extends Interactable

@export var weapon_rack: WeaponRack

func can_interact(player: Player) -> bool:
	if weapon_rack.in_range:
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.InteractItem)
	return weapon_rack.in_range
	
func interact(player: Player) -> void:
	weapon_rack.interact(player, weapon_rack.WeaponType.Bat)
	
func reticle_color() -> Color:
	return RETICLE_GREEN

func interact2(player: Player) -> void:
	if player.has_held_object():
		if player.item_slot.get_child_count() > 0:
			player.drop_item()
