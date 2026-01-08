extends Node3D
class_name Table

@export var menu: Menu
@export var area_col: CollisionShape3D
@export var plate_timer: Timer
@export var chair: Chair
@export var is_empty: bool

@onready var player: Player

var food_item: Item
var money: int

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _on_area_3d_body_entered(body: Node3D) -> void:
	var obj = body.get_parent()
	if obj.is_in_group("items") and obj.has_meta("food_id") and menu.food_id != -1:
		if obj.get_meta("food_id") == menu.food_id:
			money = randi_range(6,10)
		else:
			money = randi_range(1,3)
		area_col.set_deferred("disabled", true)
		food_item = obj as Item
		food_item.disabled = true
		plate_timer.start()
		GlobalSignal.remove_order_from_list.emit(menu.table_id)


func _on_plate_timer_timeout() -> void:
	var plate_dirty = preload("res://assets/items/plate_dirty.tscn").instantiate()
	plate_dirty.position = food_item.position
	food_item.get_parent().add_child(plate_dirty)
	food_item.queue_free()
	
	# remove npc
	chair.sitting_marker.get_child(0).queue_free()
	GlobalSignal.table_empty.emit(get_meta("table_id"))
	
	area_col.set_deferred("disabled", false)
	is_empty = true
	
	player.update_money(money)
