class_name QuestDecorator
extends QuestResource

var wrapped_quest: QuestResource

func _init(quest: QuestResource) -> void:
	wrapped_quest = quest
