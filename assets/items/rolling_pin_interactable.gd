extends Interactable

@export var item: Item

func can_interact(player: Player) -> bool:
	if item.in_range:
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.InteractItem, player.has_held_object())
		if not surface_material_override:
			surface_material_override = item.mesh.get_surface_override_material(0)
			stencil_outline_thickness = 0.02
		enable_stencil()
	return item.in_range
	
func interact(player: Player) -> void:
	disable_stencil()
	if item.disabled:
		return
	if player.item_slot.get_child_count() > 0:
		player.drop_item()
	if get_parent():
		get_parent().remove_child(self)
	item.pickup(Vector3.ZERO, Vector3(deg_to_rad(10),deg_to_rad(130),deg_to_rad(0)), player)
	if item.has_meta("food_id") and item.get_meta("food_id") == GlobalVar.PIZZA_TYPE.CHEESE_PIE:
		GlobalSignal.update_quest_objective.emit(QuestIds.MAKE_PIZZA, QuestObjs.REMOVE_PIZZA_OVEN)
	item.queue_free()
	
func reticle_color() -> Color:
	return RETICLE_GREEN

func interact2(player: Player) -> void:
	if player.has_held_object():
		if item.disabled:
			return
		if player.item_slot.get_child_count() > 0:
			player.drop_item()
