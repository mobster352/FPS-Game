extends Node3D
class_name Restaurant

const rolling_pin_item = "res://assets/items/rolling_pin.tscn"
const crate_generic_item = "res://assets/environment/restaurant/crate_generic.tscn"
const pizza_box_item = "uid://dp8cybb476vqi"

var drive_thru_menu: DriveThruMenu

@export var level:Level
@export var order_spawn: Marker3D

var table_list: Array[Dictionary]
var quest_log:QuestLog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignal.get_open_table.connect(_get_open_table)
	GlobalSignal.check_restaurant_food.connect(_check_restaurant_food)
	GlobalSignal.order_inventory_items.connect(_order_inventory_items)
	GlobalSignal.add_table.connect(_add_table)
	GlobalSignal.remove_table.connect(_remove_table)
	
	quest_log = get_tree().get_first_node_in_group("quest_log")
	
	GlobalSignal.init_restaurant.emit(self)

func _process(_delta: float) -> void:
	#print_table_list()
	pass


func _add_table(_table: Table) -> void:
	for table_dict in table_list:
		var table = table_dict.get("table") as Table
		var table_id = table_dict.get("table_id") as int
		if not table:
			table_dict.set("table", _table)
			GlobalSignal.send_table_id.emit(_table, table_id)
			return
	
	if _table.table_id:
		table_list.append(
			{
				"table": _table,
				"table_id": _table.table_id
			}
		)
		GlobalSignal.send_table_id.emit(_table, _table.table_id)
	else:
		var next_table_id:int = get_next_table_id()
		table_list.append(
			{
				"table": _table,
				"table_id": next_table_id
			}
		)
		GlobalSignal.send_table_id.emit(_table, next_table_id)


func _remove_table(_table: Table) -> void:
	var index = 0
	for table_dict in table_list:
		var table = table_dict.get("table") as Table
		if table and table == _table:
			#table_list.remove_at(index)
			table_dict.set("table", null)
			return
		index = index + 1


func print_table_list() -> void:
	print("-------------")
	for table_dict in table_list:
		var table = table_dict.get("table") as Table
		var table_id = table_dict.get("table_id") as int
		print("Table: ", table, " ID: ", table_id)
	print("-------------")


func get_next_table_id() -> int:
	if table_list.is_empty():
		return 1
	var max_id:int = 0
	for table_dict:Dictionary in table_list:
		if table_dict.get("table_id") > max_id:
			max_id = table_dict.get("table_id")
	if max_id:
		return max_id + 1
	else:
		return -1


func _get_open_table(npc_dummy:NPC_Dummy) -> void:
	for table_dict in table_list:
		var table = table_dict.get("table") as Table
		if table:
			if table.is_empty:
				GlobalSignal.assign_customer_to_table.emit(table, npc_dummy)
				return
	GlobalSignal.assign_customer_to_table.emit(null, npc_dummy)

func needs_food(food_id:int) -> bool:
	for table_dict in table_list:
		var table = table_dict.get("table") as Table
		if table:
			if table.menu.food_id == food_id:
				return true
			elif drive_thru_menu and drive_thru_menu.food_id == food_id:
				return true
	return false

func _check_restaurant_food(food_id:int) -> void:
	GlobalSignal.toggle_pointer_by_food.emit(food_id, needs_food(food_id))


func _order_inventory_items(order_items: Array[Dictionary]) -> void:
	for store_item:Dictionary in order_items:
		if store_item.has("store_item"):
			if store_item.get("store_item") == GlobalVar.StoreItem.RollingPin:
				if store_item.has("quantity"):
					for q in range(store_item.get("quantity")):
						order_spawn.add_child(preload(rolling_pin_item).instantiate())
				GlobalSignal.update_quest_objective.emit(QuestIds.BUY_INGREDIENTS, QuestObjs.BUY_ROLLING_PIN)
			if store_item.get("store_item") == GlobalVar.StoreItem.Dough:
				if store_item.has("quantity"):
					for q in range(store_item.get("quantity")):
						order_spawn.add_child(get_crate_item(GlobalVar.StoreItem.Dough))
				GlobalSignal.update_quest_objective.emit(QuestIds.BUY_INGREDIENTS, QuestObjs.BUY_DOUGH)
			if store_item.get("store_item") == GlobalVar.StoreItem.Tomato:
				if store_item.has("quantity"):
					for q in range(store_item.get("quantity")):
						order_spawn.add_child(get_crate_item(GlobalVar.StoreItem.Tomato))
				GlobalSignal.update_quest_objective.emit(QuestIds.BUY_INGREDIENTS, QuestObjs.BUY_TOMATO)
			if store_item.get("store_item") == GlobalVar.StoreItem.Cheese:
				if store_item.has("quantity"):
					for q in range(store_item.get("quantity")):
						order_spawn.add_child(get_crate_item(GlobalVar.StoreItem.Cheese))
				GlobalSignal.update_quest_objective.emit(QuestIds.BUY_INGREDIENTS, QuestObjs.BUY_CHEESE)
			if store_item.get("store_item") == GlobalVar.StoreItem.Pepperoni:
				if store_item.has("quantity"):
					for q in range(store_item.get("quantity")):
						order_spawn.add_child(get_crate_item(GlobalVar.StoreItem.Pepperoni))
			if store_item.get("store_item") == GlobalVar.StoreItem.Mushroom:
				if store_item.has("quantity"):
					for q in range(store_item.get("quantity")):
						order_spawn.add_child(get_crate_item(GlobalVar.StoreItem.Mushroom))
			if store_item.get("store_item") == GlobalVar.StoreItem.PizzaBox:
				if store_item.has("quantity"):
					var stack = preload(pizza_box_item).instantiate() as PizzaBoxStack
					stack.num_pizza_boxes = store_item.get("quantity")
					order_spawn.add_child(stack)
				GlobalSignal.update_quest_objective.emit(QuestIds.BUY_INGREDIENTS, QuestObjs.BUY_PIZZA_BOXES)


func get_crate_item(order_item: GlobalVar.StoreItem) -> Item:
		var crate = preload(crate_generic_item).instantiate()
		var interactable = crate.get_node("body/Interactable") as ObjectSpawner
		interactable.item_type = order_item
		return crate


func _on_drive_thru_spawn_init_drive_thru_menu(_drive_thru_menu:DriveThruMenu) -> void:
	drive_thru_menu = _drive_thru_menu


func _on_open_sign_init_open_sign() -> void:
	%open_sign.level = level
