extends Node3D
class_name Marker

@onready var outside_marker: Marker3D
@onready var restaurant_marker: Marker3D
@onready var queue_marker: Marker3D

func _ready() -> void:
	outside_marker = get_node("../Level_Prototype/Environment/Markers/Outside")
	restaurant_marker = get_node("../Level_Prototype/Environment/Markers/RestaurantMarker")
	queue_marker = get_node("../Level_Prototype/Environment/Markers/Queue")
