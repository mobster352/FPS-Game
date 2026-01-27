extends NavigationAgent3D
class_name ThiefNavigationAgent

var target: Node3D

func _navigation_server_map_changed(_map_rid: RID) -> void:
	if get_navigation_map() and target:
		set_target(target)
	else:
		set_random_target()

func set_random_target() -> void:
	set_target_position(NavigationServer3D.map_get_random_point(get_navigation_map(), 3, false))

func set_target(_target:Node3D) -> void:
	target = _target
	set_target_position(NavigationServer3D.map_get_closest_point(get_navigation_map(), target.global_position))

func switch_navigation_layer(old_layer:int, new_layer:int) -> void:
	set_navigation_layer_value(old_layer,false)
	set_navigation_layer_value(new_layer,true)
