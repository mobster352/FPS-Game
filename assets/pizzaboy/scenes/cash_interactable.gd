extends Interactable

@export var cash:Cash

var cash_register:CashRegister

func _ready() -> void:
	cash_register = get_tree().get_first_node_in_group("cash_register")

func can_interact(_player: Player) -> bool:
	return cash_register.is_open
	
func interact(_player: Player) -> void:
	if cash.in_register:
		cash_register.update_change(cash.cash_value, false)
	else:
		cash_register.update_change(cash.cash_value, true)
		cash.queue_free()
