extends Interactable

@export var computer: Computer
@export var mesh:MeshInstance3D

func can_interact(player: Player) -> bool:
	if computer.in_range:
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.Interact, player.has_held_object())
		if not surface_material_override:
			surface_material_override = mesh.get_surface_override_material(0)
			stencil_outline_thickness = 0.02
		enable_stencil()
	return computer.in_range
	
func interact(_player: Player) -> void:
	disable_stencil()
	computer.interact(_player)
	
func reticle_color() -> Color:
	return RETICLE_GREEN
	
func interact2(player: Player) -> void:
	if player.has_held_object():
		if player.item_slot.get_child_count() > 0:
			player.drop_item()
