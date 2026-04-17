extends Interactable

@export var cash_register:CashRegister

func can_interact(_player: Player) -> bool:
	if cash_register.in_range:
		pass
	return cash_register.in_range
	
func interact(_player: Player) -> void:
	_player.transform = cash_register.cashier_marker.transform
	_player.is_cashier = true
	cash_register.set_register_visibility(true)
