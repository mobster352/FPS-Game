extends Control

enum TabletStoreItems {
	Table_Round_A,
	Table_Round_B,
	Table_Round_B_Tablecloth_Green,
	Table_Round_B_Tablecloth_Red
}

var is_tablet_open := false
var placement_system: PlacementSystem
var player:Player

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

func _on_purchase_table_button_pressed(enum_name:String) -> void:
	if player.money < 25:
		return
	var table_node_path:String
	var table_outline_node_path:String
	match TabletStoreItems[enum_name]:
		TabletStoreItems.Table_Round_A: 
			table_node_path = Table.TablesDict.get(Table.Tables.Table_Round_A).get("table_node_path")
			table_outline_node_path = Table.TablesDict.get(Table.Tables.Table_Round_A).get("table_outline_node_path")
		TabletStoreItems.Table_Round_B:
			table_node_path = Table.TablesDict.get(Table.Tables.Table_Round_B).get("table_node_path")
			table_outline_node_path = Table.TablesDict.get(Table.Tables.Table_Round_B).get("table_outline_node_path")
		TabletStoreItems.Table_Round_B_Tablecloth_Green:
			table_node_path = Table.TablesDict.get(Table.Tables.Table_Round_B_Tablecloth_Green).get("table_node_path")
			table_outline_node_path = Table.TablesDict.get(Table.Tables.Table_Round_B_Tablecloth_Green).get("table_outline_node_path")
		TabletStoreItems.Table_Round_B_Tablecloth_Red:
			table_node_path = Table.TablesDict.get(Table.Tables.Table_Round_B_Tablecloth_Red).get("table_node_path")
			table_outline_node_path = Table.TablesDict.get(Table.Tables.Table_Round_B_Tablecloth_Red).get("table_outline_node_path")
	if not table_node_path:
		return
	var table:Table = load(table_node_path).instantiate()
	hide_tablet()
	player.tables_node.add_child(table)
	placement_system.setup_object_preview.emit(table_outline_node_path, table, table_node_path, -25)
	if is_instance_valid(quest_log):
		if quest_log.active_quest_id == Quest.QuestIds.BUY_TABLE:
			quest_log.update_quest_objective(Quest.QuestObjs.BUY_TABLE)


func _on_close_tablet_button_pressed() -> void:
	hide_tablet()
