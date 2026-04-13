extends Control

var is_tablet_open := false
var placement_system: PlacementSystem
var player:Player

const table_outline = "uid://ftktew0563fj"
const table_a2 = "uid://cx648bisbnt5"

var quest_log:QuestLog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	placement_system = get_tree().get_first_node_in_group("placement_system")
	player = get_tree().get_first_node_in_group("player")
	quest_log = get_tree().get_first_node_in_group("quest_log")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_tablet"):
		is_tablet_open = not is_tablet_open
		if is_tablet_open:
			if is_instance_valid(quest_log):
				if player.playerData.day == 1 and quest_log.active_quest_id < Quest.QuestIds.BUY_TABLE:
					return
			show_tablet()
		else:
			hide_tablet()

func show_tablet() -> void:
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GlobalSignal.freeze_player_camera.emit(true)
	is_tablet_open = true
	if is_instance_valid(quest_log):
		if quest_log.active_quest_id == Quest.QuestIds.BUY_TABLE:
			quest_log.update_quest_objective(Quest.QuestObjs.OPEN_TABLET)

func hide_tablet() -> void:
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GlobalSignal.freeze_player_camera.emit(false)
	is_tablet_open = false

func _on_purchase_button_pressed() -> void:
	hide_tablet()
	var table:Table = preload("uid://cx648bisbnt5").instantiate()
	player.tables_node.add_child(table)
	placement_system.setup_object_preview.emit(table_outline, table, table_a2, -25)
	if is_instance_valid(quest_log):
		if quest_log.active_quest_id == Quest.QuestIds.BUY_TABLE:
			quest_log.update_quest_objective(Quest.QuestObjs.BUY_TABLE)


func _on_close_tablet_button_pressed() -> void:
	hide_tablet()
