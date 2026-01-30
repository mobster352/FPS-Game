extends Node3D
class_name GameState

@onready var restaurant_back_door_marker: Marker3D

var thief_nodes: Array[Node]
var thief_targets: Array[Node]

func _ready() -> void:
	restaurant_back_door_marker = $"../Environment/Markers/RestaurantBackDoorMarker"
	

func get_random_time() -> float:
	return randf_range(10, 60)

func get_target(navigation_target:Node, has_item:bool) -> Node:
	thief_targets = get_tree().get_nodes_in_group("thief_target")
	if not thief_targets:
		return
	if navigation_target or has_item:
		return
	else:
		var target = thief_targets.pick_random()
		if navigation_target is GenericSpawner:
			if navigation_target.mesh.get_child_count() <= 0:
				return # failed to get target
		return target
