class_name FetchQuest
extends QuestDecorator

var item:StringName

func _init(quest: QuestResource, item_mesh_name:StringName) -> void:
	super(quest)
	item = item_mesh_name
