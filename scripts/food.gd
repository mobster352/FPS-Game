extends Node
class_name Food

var food_id:int
var food_name:StringName

func _init(_food_id:int, _food_name:StringName) -> void:
	food_id = _food_id
	food_name = _food_name
