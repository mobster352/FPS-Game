extends Interactable

@export var package:Package

func can_interact(player: Player) -> bool:
	if package.in_range and not package.is_disabled:
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.InteractItem, player.has_held_object())
	return package.in_range
	
func interact(player: Player) -> void:
	if package.disabled:
		return
	if player.has_held_object():
		player.drop_item()
	if get_parent():
		get_parent().remove_child(self)
	package.pickup(Vector3(deg_to_rad(0), deg_to_rad(-10), deg_to_rad(-20)), Vector3(deg_to_rad(20),deg_to_rad(180),deg_to_rad(0)), player)
	package.queue_free()
	
func interact2(player: Player) -> void:
	if player.has_held_object():
		player.drop_item()
