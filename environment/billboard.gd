extends Interactable
class_name Billboard

@export var billboard_ui: Control

var in_range := false

var quest_log:QuestLog

func _ready() -> void:
	quest_log = get_tree().get_first_node_in_group("quest_log")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false


func show_billboard_ui() -> void:
	if is_instance_valid(quest_log):
		quest_log.update_quest_objective(QuestIds.CHANGE_STORE_NAME, QuestObjs.CHANGE_STORE_NAME)
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	billboard_ui.show()


func can_interact(player: Player) -> bool:
	if in_range:
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.Interact)
	return in_range
	
func interact(player: Player) -> void:
	show_billboard_ui()
	player.freeze_camera = true
	
func reticle_color() -> Color:
	return RETICLE_GREEN
