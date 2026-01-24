extends Node3D
class_name Restaurant

const rolling_pin_item = "res://assets/items/rolling_pin.tscn"
const crate_generic_item = "res://assets/environment/restaurant/crate_generic.tscn"
const pizza_box_item = "res://assets/environment/restaurant/pizzabox_open.tscn"

@export var chair1: Chair
@export var chair2: Chair
@export var table1: Table
@export var table2: Table
@export var drive_thru_menu: DriveThruMenu
@export var order_spawn: Marker3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignal.get_open_table.connect(_get_open_table)
	GlobalSignal.check_restaurant_food.connect(_check_restaurant_food)
	GlobalSignal.order_inventory_items.connect(_order_inventory_items)

func _process(_delta: float) -> void:
	pass


func _get_open_table(npc_dummy:NPC_Dummy) -> void:
	if table1.is_empty:
		GlobalSignal.assign_customer_to_table.emit(table1,npc_dummy)
	elif table2.is_empty:
		GlobalSignal.assign_customer_to_table.emit(table2,npc_dummy)

func needs_food(food_id:int) -> bool:
	return table1.menu.food_id == food_id or table2.menu.food_id == food_id or drive_thru_menu.food_id == food_id

func _check_restaurant_food(food_id:int) -> void:
	GlobalSignal.toggle_pointer_by_food.emit(food_id, needs_food(food_id))


func _order_inventory_items(order_items: Array[Dictionary]) -> void:
	for store_item:Dictionary in order_items:
		if store_item.has("store_item"):
			if store_item.get("store_item") == GlobalVar.StoreItem.RollingPin:
				if store_item.has("quantity"):
					for q in range(store_item.get("quantity")):
						order_spawn.add_child(preload(rolling_pin_item).instantiate())
			if store_item.get("store_item") == GlobalVar.StoreItem.Dough:
				if store_item.has("quantity"):
					for q in range(store_item.get("quantity")):
						order_spawn.add_child(get_crate_item(GlobalVar.StoreItem.Dough))
			if store_item.get("store_item") == GlobalVar.StoreItem.Tomato:
				if store_item.has("quantity"):
					for q in range(store_item.get("quantity")):
						order_spawn.add_child(get_crate_item(GlobalVar.StoreItem.Tomato))
			if store_item.get("store_item") == GlobalVar.StoreItem.Cheese:
				if store_item.has("quantity"):
					for q in range(store_item.get("quantity")):
						order_spawn.add_child(get_crate_item(GlobalVar.StoreItem.Cheese))
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
					for q in range(store_item.get("quantity")):
						order_spawn.add_child(preload(pizza_box_item).instantiate())
	
		
func get_crate_item(order_item: GlobalVar.StoreItem) -> Item:
		var crate = preload(crate_generic_item).instantiate()
		var interactable = crate.get_node("body/Interactable") as ObjectSpawner
		interactable.item_type = order_item
		return crate
