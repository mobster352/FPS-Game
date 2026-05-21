class_name FetchQuest
extends QuestDecorator

var item:StringName

func _init(quest: QuestResource, item_mesh_name:StringName) -> void:
	super(quest)
	item = item_mesh_name

func get_npc_type() -> GlobalVar.NpcType:
	return wrapped_quest.npc_type
