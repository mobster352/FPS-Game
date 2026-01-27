extends Node3D
class_name GameState

@onready var thief_target_timer: Timer
@onready var restaurant_back_door_marker: Marker3D

var thief_nodes: Array[Node]
var thief_targets: Array[Node]

func _ready() -> void:
	thief_target_timer = $Timers/ThiefTargetTimer
	restaurant_back_door_marker = $"../Environment/Markers/RestaurantBackDoorMarker"
	
	thief_target_timer.wait_time = get_random_time()
	thief_target_timer.start()

func _on_thief_target_timer_timeout() -> void:
	thief_targets = get_tree().get_nodes_in_group("thief_target")
	if not thief_targets:
		thief_target_timer.wait_time = get_random_time()
		thief_target_timer.start()
		return

	thief_nodes = get_tree().get_nodes_in_group("thief")
	for thief:Thief in thief_nodes:
		if thief.navigation_target or thief.has_item:
			break
		else:
			var navigation_target = thief_targets.pick_random()
			if navigation_target is GenericSpawner:
				if navigation_target.mesh.get_child_count() <= 0:
					navigation_target = null # failed to get target
					thief_target_timer.wait_time = get_random_time()
					thief_target_timer.start()
					break
			thief.set_thief_target(navigation_target, true)
	thief_target_timer.wait_time = get_random_time()
	thief_target_timer.start()

func get_random_time() -> float:
	return randf_range(10, 60)
