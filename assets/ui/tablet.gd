class_name Tablet
extends Control

enum TabletStoreItems {
	Table_Round_A,
	Table_Round_B,
	Table_Round_B_Tablecloth_Green,
	Table_Round_B_Tablecloth_Red
}

const monitor_order_table = preload("uid://c06pjdmf0upgb")
const monitor_order_cooked = preload("uid://3qqp6fwhrt1p")
const monitor_order_ingredients = preload("uid://spry8ppndki4")
const monitor_ingredient = preload("uid://csjrxmctsxanw")

@export var grid_container:GridContainer
@export var tabs:TabContainer
@onready var tables: Control = %Tables
@onready var purchase_table_button: Button = %PurchaseTableButton

var is_tablet_open := false
var placement_system: PlacementSystem
var player:Player

var order_list: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	placement_system = get_tree().get_first_node_in_group("placement_system")
	player = get_tree().get_first_node_in_group("player")
	
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
	GlobalSignal.update_quest_objective.emit(QuestIds.BUY_TABLE, QuestObjs.OPEN_TABLET)
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


func _on_close_tablet_button_pressed() -> void:
	hide_tablet()

func _add_order(table_id:int, food_id: int) -> void:
	var monitor_order_table_instance = monitor_order_table.instantiate() as Control
	var label:Label = monitor_order_table_instance.get_child(0) as Label
	
	var monitor_order_cooked_instance = monitor_order_cooked.instantiate() as Control
	var cooked_texture:TextureRect = monitor_order_cooked_instance.get_child(0) as TextureRect
	
	var monitor_order_ingredients_instance = monitor_order_ingredients.instantiate() as Control
	var hbox:HBoxContainer = monitor_order_ingredients_instance.get_child(0) as HBoxContainer
	
	var food = GlobalVar.get_food(food_id) as Food
	if table_id == 0:
		label.text = "Drive-Thru"
		cooked_texture.texture = load(food.cooked_texture)
		for ingredient in food.ingredients:
			var new_ingredient = monitor_ingredient.instantiate() as TextureRect
			new_ingredient.texture = load(ingredient)
			hbox.add_child(new_ingredient)
	else:
		label.text = str(table_id)
		cooked_texture.texture = load(food.cooked_texture)
		for ingredient in food.ingredients:
			var new_ingredient = monitor_ingredient.instantiate() as TextureRect
			new_ingredient.texture = load(ingredient)
			hbox.add_child(new_ingredient)
	
	grid_container.add_child(monitor_order_table_instance)
	grid_container.add_child(monitor_order_cooked_instance)
	grid_container.add_child(monitor_order_ingredients_instance)
	var order = {"table_id": table_id, "food_id": food_id, "monitor_order_table": monitor_order_table_instance, "monitor_order_cooked": monitor_order_cooked_instance, "monitor_order_ingredients": monitor_order_ingredients_instance}
	order_list.append(order)

func _remove_order_from_list(table_id: int) -> void:
	var i = 0
	for order in order_list:
		if order.table_id == table_id:
			grid_container.remove_child(order.monitor_order_table)
			grid_container.remove_child(order.monitor_order_cooked)
			grid_container.remove_child(order.monitor_order_ingredients)
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


func _on_tables_visibility_changed() -> void:
	if tables.visible:
		purchase_table_button.call_deferred("grab_focus")
