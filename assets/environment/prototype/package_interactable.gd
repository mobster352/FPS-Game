extends Interactable

@export var package:Package
@export var mesh:MeshInstance3D

func can_interact(player: Player) -> bool:
	var result:bool = package.in_range and not package.is_disabled
	if result:
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.InteractItem, player.has_held_object())
		if not surface_material_override:
			surface_material_override = mesh.get_surface_override_material(0)
			stencil_outline_thickness = 0.02
		enable_stencil()
	return result
	
func interact(player: Player) -> void:
	if package.disabled:
		return
	disable_stencil()
	if player.has_held_object():
		player.drop_item()
	if get_parent():
		get_parent().remove_child(self)
	package.pickup(Vector3(deg_to_rad(0), deg_to_rad(-10), deg_to_rad(-20)), Vector3(deg_to_rad(20),deg_to_rad(180),deg_to_rad(0)), player)
	package.queue_free()
	
func interact2(player: Player) -> void:
	if player.has_held_object():
		player.drop_item()
