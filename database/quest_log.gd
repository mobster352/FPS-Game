class_name QuestLog
extends Control

@export var quests:Array[Quest]

var active_quest_id:int:
	set(value):
		active_quest_id = value
		await get_tree().create_timer(1.0).timeout
		%Description.get_child(0).hide()
		update_quest_text()

func _ready() -> void:
	active_quest_id = Quest.QuestIds.OPEN_COMPUTER

func update_quest_text() -> void:
	if quests.size() > active_quest_id:
		show()
		%Title.text = Quest.QUEST_TITLES[active_quest_id]
		%Description.text = quests[active_quest_id].description
	else:
		hide()
		

func update_quest(quest_id:int) -> void:
	if active_quest_id != quest_id:
		return
	active_quest_id += 1
	%Description.get_child(0).show()
