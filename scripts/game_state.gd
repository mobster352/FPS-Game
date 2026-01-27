extends Node3D
class_name GameState

@onready var thief_target_timer: Timer
@onready var restaurant_back_door_marker: Marker3D

signal set_thief_target(target:Node, is_item:bool)
signal clear_thief_target(has_item:bool)

var thief_targets: Array[Node]
var current_target: Node

func _ready() -> void:
	thief_target_timer = $Timers/ThiefTargetTimer
	restaurant_back_door_marker = $"../Environment/Markers/RestaurantBackDoorMarker"
	
	thief_target_timer.start()
	clear_thief_target.connect(_clear_thief_target)

func _on_thief_target_timer_timeout() -> void:
	thief_targets = get_tree().get_nodes_in_group("thief_target")
	if not thief_targets:
		thief_target_timer.start()
		return
	if current_target:
		set_thief_target.emit(current_target, false)
	else:
		current_target = thief_targets.pick_random()
		set_thief_target.emit(current_target, true)

func _clear_thief_target(has_item:bool) -> void:
	if has_item:
		return
	current_target = null
	thief_target_timer.start()
