class_name Tablet
extends Control

enum TabletStoreItems {
	Table_Round_A,
	Table_Round_B,
	Table_Round_B_Tablecloth_Green,
	Table_Round_B_Tablecloth_Red
}

@export var order_vbox:VBoxContainer
@export var tabs:TabContainer

var is_tablet_open := false
var placement_system: PlacementSystem
var player:Player

var quest_log:QuestLog
var order_list: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	placement_system = get_tree().get_first_node_in_group("placement_system")
	player = get_tree().get_first_node_in_group("player")
	quest_log = get_tree().get_first_node_in_group("quest_log")
	
	GlobalSignal.add_order.connect(_add_order)
	GlobalSignal.remove_order_from_list.connect(_remove_order_from_list)
	
	$MarginContainer/TabContainer/Tables/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/PurchaseTableButton.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_tablet"):
		is_tablet_open = not is_tablet_open
		if is_tablet_open:
			show_tablet()
		else:
			hide_tablet()

func show_tablet() -> void:
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GlobalSignal.freeze_player_camera.emit(true)
	is_tablet_open = true
	if is_instance_valid(quest_log):
		quest_log.update_quest_objective(QuestResource.QuestIds.BUY_TABLE, QuestResource.QuestObjs.OPEN_TABLET)
	$MarginContainer/TabContainer/Tables/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/PurchaseTableButton.grab_focus()

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
		quest_log.update_quest_objective(QuestResource.QuestIds.BUY_TABLE, QuestResource.QuestObjs.BUY_TABLE)


func _on_close_tablet_button_pressed() -> void:
	hide_tablet()

func _add_order(table_id:int, food_id: int) -> void:
	var monitor_order = preload("res://assets/environment/restaurant/monitor_order.tscn").instantiate() as MarginContainer
	var child = monitor_order.get_child(0) as Label
	
	var food = GlobalVar.get_food(food_id) as Food
	if table_id == 0:
		child.text = "Drive-Thru: " + food.food_name
	else:
		child.text = "Table " + str(table_id) + ": " + food.food_name
	
	order_vbox.add_child(monitor_order)
	var order = {"table_id": table_id, "food_id": food_id, "monitor_order": monitor_order}
	order_list.append(order)

func _remove_order_from_list(table_id: int) -> void:
	var i = 0
	for order in order_list:
		if order.table_id == table_id:
			order_vbox.remove_child(order.monitor_order)
			order_list.remove_at(i)
		i += 1


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("tab_left"):
		tabs.current_tab = wrapi(tabs.current_tab + 1, 0, tabs.get_tab_count())
		$MarginContainer/TabContainer/Tables/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/PurchaseTableButton.grab_focus()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("tab_right"):
		tabs.current_tab = wrapi(tabs.current_tab - 1, 0, tabs.get_tab_count())
		$MarginContainer/TabContainer/Tables/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/PurchaseTableButton.grab_focus()
		get_viewport().set_input_as_handled()
