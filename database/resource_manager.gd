extends Node

var dialogue_db:Array
var quests_db:Array
var quest_dialogue_db:Array
var quest_objective_items:Array

var fetch_quests:Dictionary[String, FetchQuest]

func _ready() -> void:
	dialogue_db = load_resource("res://resources/dialogue")
	quests_db = load_resource("res://database/quests")
	quest_dialogue_db = load_resource("res://resources/quest_dialogue")
	quest_objective_items = load_resource("res://resources/quest_objective_items")
	create_fetch_quests()

func get_dialogue_by_id(dialogue_id:StringName, index:int) -> String:
	for dialogue_resource:DialogueResource in dialogue_db:
		if dialogue_resource.id == dialogue_id:
			if dialogue_resource.lines.has(index):
				var dialogue_line:DialogueLine = dialogue_resource.lines.get(index)
				if dialogue_line:
					return dialogue_line.text
			push_error("Dialogue index is invalid")
			break
	return ""


func get_dialogue_id_for_quest(quest_id:StringName, quest_objective_id:StringName) -> StringName:
	for quest_dialogue:QuestDialogue in quest_dialogue_db:
		if quest_dialogue.quest_resource.quest_id == quest_id:
			var quest_objectives:Dictionary = quest_dialogue.quest_resource.quest_objectives.get(0)
			if not quest_objectives:
				continue
			if not quest_objectives.has(quest_objective_id):
				continue
			if not quest_dialogue.dialogue_dict.has(quest_objective_id):
				continue
			var dialogue_resource:DialogueResource = quest_dialogue.dialogue_dict.get(quest_objective_id)
			return dialogue_resource.id
	return ""


func create_fetch_quests() -> void:
	for quest_resource:QuestResource in quests_db:
		if quest_resource.quest_type != Quest.QuestType.Fetch:
			continue
		for quest_objective:Dictionary in quest_resource.quest_objectives:
			for quest_objective_item:QuestObjectiveItem in quest_objective_items:
				if quest_objective.has(quest_objective_item.quest_objective_id):
					var quest_objective_id:StringName = quest_objective_item.quest_objective_id
					var quest_item_id:StringName = quest_objective_item.quest_item_id
					if not fetch_quests.has(quest_objective_id):
						fetch_quests.set(quest_objective_id, FetchQuest.new(quest_resource, quest_item_id))


func get_random_fetch_quest() -> Quest:
	var quest_objective_id:StringName = fetch_quests.keys().pick_random()
	var fetch_quest:FetchQuest = fetch_quests.get(quest_objective_id)
	var quest_id:StringName = fetch_quest.wrapped_quest.quest_id
	var quest_item_id:StringName = fetch_quest.item
	var quest:Quest = Quest.new(quest_id, quest_objective_id, quest_item_id)
	return quest


func get_fetch_quest(quest_objective_id:StringName) -> FetchQuest:
	if not fetch_quests.has(quest_objective_id):
		push_error("Quest objective id not found: ", quest_objective_id)
		return null
	return fetch_quests.get(quest_objective_id)


func load_resource(path: String) -> Array:
	var resource_array:Array
	var dir = ResourceLoader.list_directory(path)
	for ent_name in dir:
		if ent_name.ends_with(".tres"):
			var ent_path: String = path + "/" + ent_name
			var res = load(ent_path)
			resource_array.append(res)
	return resource_array
