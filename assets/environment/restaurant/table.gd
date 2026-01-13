extends Node3D
class_name Table

@export var menu: Menu
@export var area_col: CollisionShape3D
@export var plate_timer: Timer
@export var chair: Chair
@export var is_empty := true
@export var dialogue_box: DialogueBox
@export var npc: NPC_Dummy
@export var pointer: Node3D

@onready var player: Player

var food_item: Item
var money: int
var table_id: int

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	GlobalSignal.assign_customer_to_table.connect(_assign_customer_to_table)
	GlobalSignal.pickup_food.connect(_pickup_food)
	GlobalSignal.drop_food.connect(_drop_food)
	table_id = get_meta("table_id")

func _on_area_3d_body_entered(body: Node3D) -> void:
	var obj = body.get_parent()
	if obj.is_in_group("items") and obj.has_meta("food_id") and menu.food_id != -1:
		if obj.get_meta("food_id") == menu.food_id:
			money = randi_range(6,10)
			dialogue_box.text = dialogue_box.get_good_order_delivered_text()
		else:
			money = randi_range(1,3)
			dialogue_box.text = dialogue_box.get_bad_order_delivered_text()
		dialogue_box.show()
		area_col.set_deferred("disabled", true)
		food_item = obj as Item
		food_item.disabled = true
		plate_timer.start()
		GlobalSignal.remove_order_from_list.emit(menu.table_id)
		GlobalSignal.check_restaurant_food.emit(obj.get_meta("food_id"))

func _on_plate_timer_timeout() -> void:
	var plate_dirty = preload("res://assets/items/plate_dirty.tscn").instantiate()
	plate_dirty.position = food_item.position
	food_item.get_parent().add_child(plate_dirty)
	food_item.queue_free()
	
	# remove npc
	GlobalSignal.remove_customer.emit(npc)
	npc = null
	dialogue_box = null
	GlobalSignal.table_empty.emit(table_id)
	
	area_col.set_deferred("disabled", false)
	is_empty = true
	
	player.update_money(money)


func _assign_customer_to_table(_table:Table,_npc_dummy:NPC_Dummy) -> void:
	if self == _table:
		is_empty = false


func _pickup_food(food_id:int) -> void:
	if menu.food_id and menu.food_id == food_id:
		pointer.show()


func _drop_food(food_id:int) -> void:
	if menu.food_id and menu.food_id == food_id:
		pointer.hide()
