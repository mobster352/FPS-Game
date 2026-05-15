extends Interactable

@export var item: Item

var quest_log:QuestLog

func _ready() -> void:
	quest_log = get_tree().get_first_node_in_group("quest_log")

func can_interact(player: Player) -> bool:
	#if item.disabled:
		#player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.None, player.has_held_object())
	if item.in_range:
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.InteractItem, player.has_held_object())
	return item.in_range
	
func interact(player: Player) -> void:
	if item.disabled:
		return
	if player.item_slot.get_child_count() > 0:
		player.drop_item()
	if get_parent():
		get_parent().remove_child(self)
	item.pickup(Vector3.ZERO, Vector3(deg_to_rad(10),deg_to_rad(130),deg_to_rad(0)), player)
	if is_instance_valid(quest_log) and item.has_meta("food_id") and item.get_meta("food_id") == GlobalVar.PIZZA_TYPE.CHEESE_PIE:
		quest_log.update_quest_objective(QuestIds.MAKE_PIZZA, QuestObjs.REMOVE_PIZZA_OVEN)
	item.queue_free()
	
func reticle_color() -> Color:
	return RETICLE_GREEN

func interact2(player: Player) -> void:
	if player.has_held_object():
		if item.disabled:
			return
		if player.item_slot.get_child_count() > 0:
			player.drop_item()
