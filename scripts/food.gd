extends Node
class_name Food

var food_id:int
var food_name:StringName
var ingredients:Array[StringName]
var cooked_texture:StringName

func _init(_food_id:int, _food_name:StringName, _ingredients:Array[StringName], _cooked_texture:StringName) -> void:
	food_id = _food_id
	food_name = _food_name
	ingredients = _ingredients
	cooked_texture = _cooked_texture
