extends Interactable
class_name ObjectSpawner

@export var item: Item
@export var mesh: MeshInstance3D
@export var item_type: ItemType

var mesh_path: StringName
var scene_path: StringName
var item_name: StringName

enum ItemType {
	None,
	Dough,
	Cheese,
	Tomato,
	Pepperoni,
	Mushroom
}

const TOP_LEFT_POS = Vector3(0.35,0,0.3)
const TOP_RIGHT_POS = Vector3(-0.35,0,0.3)
const BOTTOM_LEFT_POS = Vector3(0.35,0,-0.3)
const BOTTOM_RIGHT_POS = Vector3(-0.35,0,-0.3)

var object_array : Array[Node3D]

func _ready() -> void:
	if item_type == ItemType.Dough:
		mesh_path = "res://assets/kaykit/restaurant/food_ingredient_dough.gltf"
		scene_path = "res://assets/environment/restaurant/food_ingredient_dough.tscn"
		item_name = "dough"
	elif item_type == ItemType.Cheese:
		mesh_path = "res://assets/kaykit/restaurant/food_ingredient_cheese.gltf"
		scene_path = "res://assets/items/food_ingredient_cheese.tscn"
		item_name = "cheese"
	elif item_type == ItemType.Tomato:
		mesh_path = "res://assets/kaykit/restaurant/food_ingredient_tomato.gltf"
		scene_path = "res://assets/items/food_ingredient_tomato.tscn"
		item_name = "tomato"
	elif item_type == ItemType.Pepperoni:
		mesh_path = "res://assets/kaykit/restaurant/food_ingredient_pepperoni.gltf"
		scene_path = "res://assets/items/food_ingredient_pepperoni.tscn"
		item_name = "pepperoni"
	elif item_type == ItemType.Mushroom:
		mesh_path = "res://assets/kaykit/restaurant/food_ingredient_mushroom.gltf"
		scene_path = "res://assets/items/food_ingredient_mushroom.tscn"
		item_name = "mushroom"
	if item.has_meta("count"):
		for i in range(item.get_meta("count")):
			add_object()

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
