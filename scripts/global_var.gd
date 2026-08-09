extends Node

const SAVE_SLOT_1 := "user://save_slot_1.tres"
const SAVE_SLOT_2 := "user://save_slot_2.tres"
const SAVE_SLOT_3 := "user://save_slot_3.tres"

#food_id
enum PIZZA_TYPE {
	NONE,
	PEPPERONI,
	CHEESE,
	MUSHROOM,
	PEPPERONI_PIE,
	CHEESE_PIE,
	MUSHROOM_PIE
}

enum StoreItem {
	None,
	RollingPin,
	Dough,
	Tomato,
	Cheese,
	Pepperoni,
	Mushroom,
	PizzaBox
}

enum InputDevice {
	MOUSE_KEYBOARD,
	CONTROLLER
}

var is_demo:bool = false

var mesh_to_item_array: Array[Dictionary] = [
	{
		"name": "dough_mesh",
		"item": "res://assets/environment/restaurant/food_ingredient_dough.tscn"
	},
	{
		"name": "cheese_slice_plate_mesh",
		"item": "res://assets/items/cheese_slice_plate_item.tscn"
	},
	{
		"name": "mushroom_slice_plate_mesh",
		"item": "res://assets/items/mushroom_slice_plate_item.tscn"
	},
	{
		"name": "pepperoni_slice_plate_mesh",
		"item": "res://assets/items/pepperoni_slice_plate_item.tscn"
	},
	{
		"name": "plate_dirty_mesh",
		"item": "res://assets/items/plate_dirty.tscn"
	},
	{
		"name": "crate_mesh",
		"item": "res://assets/environment/restaurant/crate_generic.tscn"
	},
	{
		"name": "dough_base_mesh",
		"item": "res://assets/items/food_ingredient_dough_base.tscn"
	},
	{
		"name": "rolling_pin_mesh",
		"item": "res://assets/items/rolling_pin.tscn",
		"mesh": "res://assets/items/rollingpin_mesh.tscn"
	},
	{
		"name": "food_ingredient_tomato_mesh",
		"item": "res://assets/items/food_ingredient_tomato.tscn"
	},
	{
		"name": "food_ingredient_cheese_mesh",
		"item": "res://assets/items/food_ingredient_cheese.tscn"
	},
	{
		"name": "food_ingredient_mushroom_mesh",
		"item": "res://assets/items/food_ingredient_mushroom.tscn"
	},
	{
		"name": "food_ingredient_pepperoni_mesh",
		"item": "res://assets/items/food_ingredient_pepperoni.tscn"
	},
	{
		"name": "food_ingredient_pepperoni_pizza_mesh",
		"item": "res://assets/items/food_pizza_pepperoni_plated.tscn"
	},
	{
		"name": "food_ingredient_mushroom_pizza_mesh",
		"item": "res://assets/items/food_pizza_mushroom_plated.tscn"
	},
	{
		"name": "food_ingredient_cheese_pizza_mesh",
		"item": "res://assets/items/food_pizza_cheese_plated.tscn"
	},
	{
		"name": "pizza_box_open_mesh",
		"item": "res://assets/environment/restaurant/pizzabox_open.tscn"
	},
	{
		"name": "coin_a_mesh",
		"item": "res://assets/items/coin_a.tscn"
	},
	{
		"name": "spellbook_closed_mesh",
		"item": "uid://chpxpw23sr103"
	},
	{
		"name": "sword_1handed_mesh",
		"item": "uid://23ccnbtvgx1w"
	},
	{
		"name": "dagger_mesh",
		"item": "uid://cgcjf3hk4t4r1"
	},
	{
		"name": "axe_2handed_mesh",
		"item": "uid://ca5w8wrqv4v8g"
	},
	{
		"name": "package_mesh",
		"item": "uid://chvbwj2atdffs"
	}
]

var food_items: Array[Food] = [
	Food.new(PIZZA_TYPE.PEPPERONI,"Pepperoni Pizza Slice", ["uid://kkeq2ldyfqbi", "uid://ck65yw2kspsmo", "uid://bmy584xa04imx", "uid://bgudwc767qkkw"], "uid://cseaxawpmam36"),
	Food.new(PIZZA_TYPE.CHEESE,"Cheese Pizza Slice", ["uid://kkeq2ldyfqbi", "uid://ck65yw2kspsmo", "uid://bmy584xa04imx"], "uid://c2osof6vauqdh"),
	Food.new(PIZZA_TYPE.MUSHROOM,"Mushroom Pizza Slice", ["uid://kkeq2ldyfqbi", "uid://ck65yw2kspsmo", "uid://bmy584xa04imx", "uid://clgt1vp0t555g"], "uid://b0un28s5ytrwu"),
	
	Food.new(PIZZA_TYPE.PEPPERONI_PIE, "Pepperoni Pizza", ["uid://kkeq2ldyfqbi", "uid://ck65yw2kspsmo", "uid://bmy584xa04imx", "uid://bgudwc767qkkw"], "uid://dtk3hl0r672fw"),
	Food.new(PIZZA_TYPE.CHEESE_PIE, "Cheese Pizza", ["uid://kkeq2ldyfqbi", "uid://ck65yw2kspsmo", "uid://bmy584xa04imx"], "uid://cy4of0wxkpuxe"),
	Food.new(PIZZA_TYPE.MUSHROOM_PIE, "Mushroom Pizza", ["uid://kkeq2ldyfqbi", "uid://ck65yw2kspsmo", "uid://bmy584xa04imx", "uid://clgt1vp0t555g"], "uid://ceboasx34ho1v")
]

var show_tips := true

var save_slot := 1

enum NpcType {
	None,
	Any,
	Default,
	Knight,
	Rogue,
	Rogue_Hooded,
	Mage,
	Barbarian
}
var npc_skins:Dictionary[StringName, NpcType] = {
	"uid://bbedpve12ikmy": NpcType.Knight,
	"uid://bxx4vua8kbs4h": NpcType.Rogue,
	"uid://vttdfwcbjkgk": NpcType.Rogue_Hooded,
	"uid://bygykan821e7t": NpcType.Mage,
	"uid://cwafteu2fqaol": NpcType.Barbarian,
	#"uid://btlcpec1pk0f4": NpcType.Default
}

var slice_of_the_day: GlobalVar.PIZZA_TYPE

func get_random_food_by_level(level:int) -> int:
	match level:
		1:
			return [PIZZA_TYPE.CHEESE_PIE, slice_of_the_day].pick_random()
		2:
			return [PIZZA_TYPE.CHEESE_PIE, slice_of_the_day].pick_random()
		3:
			return [PIZZA_TYPE.PEPPERONI_PIE, PIZZA_TYPE.CHEESE_PIE, slice_of_the_day].pick_random()
		_:
			return [PIZZA_TYPE.PEPPERONI_PIE, PIZZA_TYPE.CHEESE_PIE, PIZZA_TYPE.MUSHROOM_PIE, slice_of_the_day].pick_random()


func get_random_food_by_level_for_drive_thru(level:int) -> int:
	match level:
		1:
			return [PIZZA_TYPE.CHEESE_PIE].pick_random()
		2:
			return [PIZZA_TYPE.CHEESE_PIE].pick_random()
		3:
			return [PIZZA_TYPE.PEPPERONI_PIE, PIZZA_TYPE.CHEESE_PIE].pick_random()
		_:
			return [PIZZA_TYPE.PEPPERONI_PIE, PIZZA_TYPE.CHEESE_PIE, PIZZA_TYPE.MUSHROOM_PIE].pick_random()


func get_random_slice_by_level(level:int) -> PIZZA_TYPE:
	match level:
		1:
			return [PIZZA_TYPE.CHEESE].pick_random()
		2:
			return [PIZZA_TYPE.CHEESE].pick_random()
		3:
			return [PIZZA_TYPE.PEPPERONI, PIZZA_TYPE.CHEESE].pick_random()
		_:
			return [PIZZA_TYPE.PEPPERONI, PIZZA_TYPE.CHEESE, PIZZA_TYPE.MUSHROOM].pick_random()


func get_food(food_id:int) -> Food:
	for food in food_items:
		if food.food_id == food_id:
			return food
	return null

func get_item_from_mesh(mesh_name: StringName) -> Item:
	for mti in mesh_to_item_array:
		if mti.name == mesh_name:
			return load(mti.item).instantiate()
	return null

func get_mesh_from_array(mesh_name: StringName) -> Node3D:
	for mti in mesh_to_item_array:
		if mti.name == mesh_name:
			return load(mti.mesh).instantiate()
	return null
	
func get_save_slot() -> String:
	if save_slot == 1:
		return SAVE_SLOT_1
	elif save_slot == 2:
		return SAVE_SLOT_2
	else:
		return SAVE_SLOT_3
		
func get_save_slot_by_id(slot:int) -> String:
	if slot == 1:
		return SAVE_SLOT_1
	elif slot == 2:
		return SAVE_SLOT_2
	else:
		return SAVE_SLOT_3


func get_pizza_type_from_name(mesh_name:String) -> PIZZA_TYPE:
	match mesh_name:
		"food_ingredient_cheese_pizza_mesh":
			return PIZZA_TYPE.CHEESE_PIE
		"food_ingredient_pepperoni_pizza_mesh":
			return PIZZA_TYPE.PEPPERONI_PIE
		"food_ingredient_mushroom_pizza_mesh":
			return PIZZA_TYPE.MUSHROOM_PIE
		_:
			return PIZZA_TYPE.NONE

var force_customer_walk_in:bool = false
var time_since_customer_walked_in:float = 60.0
func _process(delta: float) -> void:
	if !force_customer_walk_in:
		time_since_customer_walked_in += delta
		if time_since_customer_walked_in >= 60.0:
			force_customer_walk_in = true
