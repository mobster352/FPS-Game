extends Interactable

@export var pizza_oven: PizzaOven
@export var mesh:MeshInstance3D

func can_interact(player: Player) -> bool:
	if pizza_oven.in_range and not pizza_oven.is_locked:
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.Interact, player.has_held_object())
		if not surface_material_override:
			surface_material_override = mesh.get_surface_override_material(0)
			stencil_outline_thickness = 0.02
		enable_stencil()
	return pizza_oven.in_range and not pizza_oven.is_locked
	
func interact(_player: Player) -> void:
	disable_stencil()
	pizza_oven.toggle_door()
	
func reticle_color() -> Color:
	return RETICLE_GREEN

func interact2(player: Player) -> void:
	if player.has_held_object():
		player.drop_item()
