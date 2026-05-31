class_name DeliveryQuest
extends QuestDecorator

var item:StringName
var room_number:int

func _init(quest: QuestResource, room_no:int, item_mesh_name:StringName) -> void:
	super(quest)
	room_number = room_no
	item = item_mesh_name
