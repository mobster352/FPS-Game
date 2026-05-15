extends Cookable

@export var item: Item
var quest_log:QuestLog

func _ready() -> void:
	quest_log = get_tree().get_first_node_in_group("quest_log")

func can_cook(player:Player) -> bool:
	if player.item_slot.get_child_count() == 1:
		var held_item = player.item_slot.get_child(0)
		if item.in_range and held_item.has_meta("name"):
			player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.Cook, player.has_held_object())
	return item.in_range
	
func cook(player: Player) -> void:
	if player.item_slot.get_child_count() == 1:
		var held_item = player.item_slot.get_child(0)
		if held_item.has_meta("name"):
			if held_item.get_meta("name") == "rolling_pin_mesh":
				var parent = item.get_parent()
				var dough_base = preload("res://assets/items/food_ingredient_dough_base.tscn").instantiate() as Item
				parent.add_child(dough_base)
				dough_base.global_position = item.rigid_body.global_position
				item.queue_free()
				if is_instance_valid(quest_log):
					quest_log.update_quest_objective(QuestResource.QuestIds.MAKE_PIZZA, "Roll out the dough ball into a pizza base")
	
func reticle_color() -> Color:
	return RETICLE_GREEN
