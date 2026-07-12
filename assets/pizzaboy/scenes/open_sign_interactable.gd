extends Interactable

@export var open_sign:OpenSign
@export var mesh:MeshInstance3D

func can_interact(player: Player) -> bool:
	if open_sign.in_range:
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.Interact)
		if not surface_material_override:
			surface_material_override = mesh.get_surface_override_material(0)
			stencil_outline_thickness = 0.02
		enable_stencil()
	return open_sign.in_range
	
func interact(_player: Player) -> void:
	disable_stencil()
	open_sign.interact()
	
func reticle_color() -> Color:
	return RETICLE_WHITE
