extends Interactable

@export var weapon_rack: WeaponRack

func can_interact(player: Player) -> bool:
	return weapon_rack.in_range
	
func interact(player: Player) -> void:
	weapon_rack.interact(player, weapon_rack.WeaponType.Bat)
	
func reticle_color() -> Color:
	return RETICLE_GREEN
