extends Interactable

@export var cash_register:CashRegister
@export var mesh:MeshInstance3D

func can_interact(player: Player) -> bool:
	var result:bool = cash_register.in_range
	if result and not player.is_cashier:
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.Interact, player.has_held_object())
		if not surface_material_override:
			surface_material_override = mesh.get_surface_override_material(0)
			stencil_outline_thickness = 0.005
		enable_stencil()
	return result
	
func interact(_player: Player) -> void:
	if not _player.is_cashier:
		disable_stencil()
		_player.transform = cash_register.cashier_marker.global_transform
		_player.is_cashier = true
		cash_register.set_register_visibility(true)
