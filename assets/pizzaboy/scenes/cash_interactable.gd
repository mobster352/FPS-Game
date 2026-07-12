extends Interactable

@export var cash:Cash

var cash_register:CashRegister

func _ready() -> void:
	cash_register = get_tree().get_first_node_in_group("cash_register")

func can_interact(player: Player) -> bool:
	var mesh:MeshInstance3D
	if cash.body.has_node("cash_1/Cash"):
		mesh = cash.body.get_node("cash_1/Cash")
	elif cash.body.has_node("cash_5/Cash"):
		mesh = cash.body.get_node("cash_5/Cash")
	elif cash.body.has_node("cash_10/Cash"):
		mesh = cash.body.get_node("cash_10/Cash")
	elif cash.body.has_node("cash_20/Cash"):
		mesh = cash.body.get_node("cash_20/Cash")
	elif cash.body.has_node("cash_50/Cash"):
		mesh = cash.body.get_node("cash_50/Cash")
	player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.Interact, player.has_held_object())
	if not surface_material_override and mesh:
		surface_material_override = mesh.get_surface_override_material(0)
		stencil_outline_thickness = 0.2
		stencil_color = Color.YELLOW
	enable_stencil()
	return cash_register.is_open
	
func interact(_player: Player) -> void:
	disable_stencil()
	if cash.in_register:
		cash_register.update_change(cash.cash_value, false)
	else:
		cash_register.update_change(cash.cash_value, true)
		cash.queue_free()
