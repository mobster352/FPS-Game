extends Node
class_name ObjectSpawner

const TOP_LEFT_POS = Vector3(0.35,0,0.3)
const TOP_RIGHT_POS = Vector3(-0.35,0,0.3)
const BOTTOM_LEFT_POS = Vector3(0.35,0,-0.3)
const BOTTOM_RIGHT_POS = Vector3(-0.35,0,-0.3)

var object_array : Array[Node3D]

func add_object() -> void:
	pass
	
func remove_object() -> Node3D:
	return null
