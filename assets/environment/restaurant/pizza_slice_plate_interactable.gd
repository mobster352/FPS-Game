extends Interactable

@export var item: Item
@export var mesh:MeshInstance3D

func can_interact(player: Player) -> bool:
	if item.in_range:
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.InteractItem, player.has_held_object())
		if not surface_material_override:
			surface_material_override = mesh.get_surface_override_material(0)
			stencil_outline_thickness = 0.02
		enable_stencil()
	return item.in_range
	
func interact(player: Player) -> void:
	if item.disabled:
		return
	disable_stencil()
	if player.has_held_object():
		player.drop_item()
	if get_parent():
		get_parent().remove_child(self)
	item.pickup(Vector3.ZERO, Vector3(deg_to_rad(10),deg_to_rad(130),deg_to_rad(0)), player)
	item.queue_free()
	
func interact2(player: Player) -> void:
	if player.has_held_object():
		player.drop_item()
	
func reticle_color() -> Color:
	return RETICLE_GREEN
