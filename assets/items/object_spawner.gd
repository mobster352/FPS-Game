extends Interactable
class_name ObjectSpawner

@export var item: Item
@export var mesh: MeshInstance3D
@export var item_type: GlobalVar.StoreItem

var mesh_path: StringName
var scene_path: StringName
var item_name: StringName
var mesh_name: StringName

const TOP_LEFT_POS = Vector3(0.35,0,0.3)
const TOP_RIGHT_POS = Vector3(-0.35,0,0.3)
const BOTTOM_LEFT_POS = Vector3(0.35,0,-0.3)
const BOTTOM_RIGHT_POS = Vector3(-0.35,0,-0.3)

var object_array : Array[Node3D]

func _ready() -> void:
	if item_type == GlobalVar.StoreItem.Dough:
		mesh_path = "res://assets/kaykit/restaurant/food_ingredient_dough.gltf"
		scene_path = "res://assets/environment/restaurant/food_ingredient_dough.tscn"
		item_name = "dough"
		mesh_name = "dough_mesh"
	elif item_type == GlobalVar.StoreItem.Cheese:
		mesh_path = "res://assets/kaykit/restaurant/food_ingredient_cheese.gltf"
		scene_path = "res://assets/items/food_ingredient_cheese.tscn"
		item_name = "cheese"
		mesh_name = "food_ingredient_cheese_mesh"
	elif item_type == GlobalVar.StoreItem.Tomato:
		mesh_path = "res://assets/kaykit/restaurant/food_ingredient_tomato.gltf"
		scene_path = "res://assets/items/food_ingredient_tomato.tscn"
		item_name = "tomato"
		mesh_name = "food_ingredient_tomato_mesh"
	elif item_type == GlobalVar.StoreItem.Pepperoni:
		mesh_path = "res://assets/kaykit/restaurant/food_ingredient_pepperoni.gltf"
		scene_path = "res://assets/items/food_ingredient_pepperoni.tscn"
		item_name = "pepperoni"
		mesh_name = "food_ingredient_pepperoni_mesh"
	elif item_type == GlobalVar.StoreItem.Mushroom:
		mesh_path = "res://assets/kaykit/restaurant/food_ingredient_mushroom.gltf"
		scene_path = "res://assets/items/food_ingredient_mushroom.tscn"
		item_name = "mushroom"
		mesh_name = "food_ingredient_mushroom_mesh"
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

func can_interact(_player: Player) -> bool:
	return false
	
func interact(_player: Player) -> void:
	pass
	
func reticle_color() -> Color:
	return RETICLE_WHITE
