extends Node3D
class_name GameState

const THIEF_SPAWNER = preload("uid://b5focl0l18uhf")

@onready var restaurant_back_door_marker: Marker3D
@onready var level: Level = $".."

var thief_nodes: Array[Node]
var thief_targets: Array[Node]
var player:Player

func _ready() -> void:
	restaurant_back_door_marker = $"../Environment/Markers/RestaurantBackDoorMarker"
	GlobalSignal.level_up.connect(_level_up)


func get_random_time() -> float:
	return randf_range(10, 60)

func get_target(navigation_target:Node, has_item:bool) -> Node:
	thief_targets = get_tree().get_nodes_in_group("thief_target")
	if not thief_targets:
		return null
	if navigation_target or has_item:
		return null
	else:
		var target = thief_targets.pick_random()
		if navigation_target is GenericSpawner:
			if navigation_target.mesh.get_child_count() <= 0:
				return null # failed to get target
		return target


func _level_up(value:int) -> void:
	if value == 3:
		create_thief_spawner()


func _on_player_player_loaded(_player:Player) -> void:
	player = _player
	if player.level >= 3:
		create_thief_spawner()
	GlobalVar.slice_of_the_day = GlobalVar.get_random_slice_by_level(player.level)
	GlobalSignal.slice_of_the_day_ready.emit()


func create_thief_spawner() -> void:
	var thief_spawner:ThiefSpawner = THIEF_SPAWNER.instantiate()
	thief_spawner.game_state = self
	thief_spawner.endPathMarker = %EndPathMarker
	%ThiefSpawnerMarker.add_child.call_deferred(thief_spawner)
