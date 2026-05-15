class_name QuestLog
extends Control

const quest_scene:PackedScene = preload("uid://b3utve62uqxuv")

var active_quests:Array[Quest]

var quests_db:Array[QuestResource]

func _ready() -> void:
	load_quests("res://database/quests")


func get_quest_resource_from_db(quest_id:StringName) -> QuestResource:
	for quest:QuestResource in quests_db:
		if quest.quest_id == quest_id:
			return quest
	return null


func add_quest(quest_id:StringName) -> void:
	if is_on_quest(quest_id):
		return
		
	var quest_resource:QuestResource = get_quest_resource_from_db(quest_id)
	
	if not quest_resource:
		push_error("Quest not found during add_quest: ", quest_id)
		return
	
	var new_quest = quest_scene.instantiate() as Quest
	new_quest.quest_id = quest_id
	new_quest.quest_name = quest_resource.quest_title
	new_quest.quest_objectives = quest_resource.quest_objectives
	%Quests.add_child(new_quest)
	active_quests.append(new_quest)


func remove_quest(quest_id:StringName) -> void:
	var index:int = 0
	for quest:Quest in active_quests:
		if quest.quest_id == quest_id:
			active_quests.remove_at(index)
			break
		index += 1
	for quest:Quest in %Quests.get_children():
		if quest.quest_id == quest_id:
			%Quests.remove_child(quest)
			break


func is_on_quest(quest_id:StringName) -> bool:
	for quest:Quest in active_quests:
		if quest.quest_id == quest_id:
			return true
	return false


func print_active_quests() -> void:
	print("Printing Active Quests...")
	for quest:Quest in active_quests:
		print(quest.quest_data.quest_name)
	print("End Print")


func update_quest_objective(quest_id:StringName, quest_objective_id:StringName) -> void:
	if not is_on_quest(quest_id):
		return
	var this_quest:Quest
	for quest:Quest in active_quests:
		if quest.quest_id == quest_id:
			for quest_obj:Quest.QuestObjective in quest.quest_data.objectives:
				if quest_obj.obj_id == quest_objective_id and not quest_obj.status:
					quest_obj.status = true
					this_quest = quest
	if not this_quest:
		return
	for quest:Quest in %Quests.get_children():
		if quest.quest_id == quest_id:
			for quest_obj_label:RichTextLabel in quest.quest_objectives_vbox.get_children():
				var quest_obj:Quest.QuestObjective = quest.quest_data.get_quest_objective(quest_objective_id)
				if not quest_obj:
					continue
				var parsed_text = quest_obj_label.get_parsed_text()
				if parsed_text == quest_obj.obj_name:
					quest_obj_label.text = "[font_size=14][outline_color=black][outline_size=3][color=green][s]%s[/s][/color][/outline_size][/outline_color][/font_size]" % quest_obj.obj_name
	var is_quest_finished:bool = true
	for quest_obj:Quest.QuestObjective in this_quest.quest_data.objectives:
		if not quest_obj.status:
			is_quest_finished = false
			break
	if is_quest_finished:
		remove_quest(this_quest.quest_id)
		GlobalSignal.add_xp.emit(5)
		var next_quest:StringName = get_next_quest(this_quest.quest_id)
		if next_quest != "":
			add_quest(next_quest)

func get_next_quest(quest_id:StringName) -> StringName:
	match quest_id:
		QuestIds.BUY_INGREDIENTS:
			return QuestIds.MOVE_PRODUCTS
		QuestIds.MOVE_PRODUCTS:
			return QuestIds.MAKE_PIZZA
		QuestIds.MAKE_PIZZA:
			return QuestIds.PLACE_PIZZA
		QuestIds.PLACE_PIZZA:
			return QuestIds.BUY_TABLE
		QuestIds.BUY_TABLE:
			return QuestIds.CHANGE_STORE_NAME
		QuestIds.CHANGE_STORE_NAME:
			return QuestIds.OPEN_PIZZERIA
		QuestIds.OPEN_PIZZERIA:
			return QuestIds.SERVE_CUSTOMERS
		QuestIds.SERVE_CUSTOMERS:
			return QuestIds.CLOSE_PIZZERIA
		_:
			return ""


func load_quests(path: String) -> void:
	var dir = ResourceLoader.list_directory(path)
	for ent_name in dir:
		if ent_name.ends_with(".tres"):
			var ent_path: String = path + "/" + ent_name
			var quest = load(ent_path)
			#print("Loaded quest: " + ent_path)
			quests_db.append(quest)
