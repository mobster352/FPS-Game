class_name Quest
extends RefCounted

var quest_id:StringName
var quest_objective_id:StringName
var quest_item_id:StringName
var dialogue_id:StringName

enum QuestType {
	None,
	Fetch
}

func _init(_quest_id:StringName, _quest_objective_id:StringName, _quest_item_id:StringName) -> void:
	quest_id = _quest_id
	quest_objective_id = _quest_objective_id
	quest_item_id = _quest_item_id
	dialogue_id = ResourceManager.get_dialogue_id_for_quest(quest_id, quest_objective_id)
