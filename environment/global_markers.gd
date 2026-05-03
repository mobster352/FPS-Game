extends Node3D
class_name Marker

signal update_markers

@onready var outside_marker: Marker3D
@onready var restaurant_marker: Marker3D

@onready var queue_marker: Marker3D
@onready var queue2_marker: Marker3D
@onready var queue3_marker: Marker3D

var queue1_npc: NPC_Dummy
var queue2_npc: NPC_Dummy
var queue3_npc: NPC_Dummy

func _ready() -> void:
	if not update_markers.is_connected(_update_markers):
		update_markers.connect(_update_markers)


func _update_markers() -> void:
	if has_node("/root/Node/Game/Level/Environment/Markers"):
		outside_marker = get_node("/root/Node/Game/Level/Environment/Markers/Outside")
		restaurant_marker = get_node("/root/Node/Game/Level/Environment/Markers/RestaurantMarker")
		queue_marker = get_node("/root/Node/Game/Level/Environment/Markers/Queue")
		queue2_marker = get_node("/root/Node/Game/Level/Environment/Markers/Queue2")
		queue3_marker = get_node("/root/Node/Game/Level/Environment/Markers/Queue3")
