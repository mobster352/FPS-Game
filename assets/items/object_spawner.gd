extends Interactable
class_name ObjectSpawner

@export var item: Item
@export var mesh: Node3D

const TOP_LEFT_POS = Vector3(0.35,0,0.3)
const TOP_RIGHT_POS = Vector3(-0.35,0,0.3)
const BOTTOM_LEFT_POS = Vector3(0.35,0,-0.3)
const BOTTOM_RIGHT_POS = Vector3(-0.35,0,-0.3)

var object_array : Array[Node3D]

func add_object() -> void:
	pass
	
func remove_object() -> Node3D:
	return null

func _get_next_pos() -> Vector3:
	var index = posmod(object_array.size(), 4)
	match index:
		0:
			return TOP_LEFT_POS
		1:
			return TOP_RIGHT_POS
		2:
			return BOTTOM_LEFT_POS
		3:
			return BOTTOM_RIGHT_POS
	return Vector3.ZERO

func can_interact() -> bool:
	return false
	
func interact(_player: Player) -> void:
	pass
	
func reticle_color() -> Color:
	return RETICLE_WHITE
