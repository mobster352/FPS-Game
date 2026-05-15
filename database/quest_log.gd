class_name QuestLog
extends Control

const quest_scene:PackedScene = preload("uid://b3utve62uqxuv")

var active_quests:Array[Quest]

var quests_db:Array[QuestResource]

func _ready() -> void:
	load_quests("res://database/quests/")
	#add_quest(QuestResource.QuestIds.BUY_INGREDIENTS)
	#await get_tree().create_timer(2).timeout
	#update_quest_objective(QuestResource.QuestIds.BUY_INGREDIENTS, QuestResource.QuestObjs.BUY_ROLLING_PIN)
	#await get_tree().create_timer(2).timeout
	#update_quest_objective(QuestResource.QuestIds.BUY_INGREDIENTS, QuestResource.QuestObjs.BUY_DOUGH)
	#await get_tree().create_timer(2).timeout
	#update_quest_objective(QuestResource.QuestIds.BUY_INGREDIENTS, QuestResource.QuestObjs.BUY_TOMATO)
	#await get_tree().create_timer(2).timeout
	#update_quest_objective(QuestResource.QuestIds.BUY_INGREDIENTS, QuestResource.QuestObjs.BUY_CHEESE)


func get_quest_resource_from_db(quest_id:QuestResource.QuestIds) -> QuestResource:
	for quest:QuestResource in quests_db:
		if quest.id == quest_id:
			return quest
	return null


func add_quest(quest_id:QuestResource.QuestIds) -> void:
	if is_on_quest(quest_id):
		return
		
	var quest_resource:QuestResource = get_quest_resource_from_db(quest_id)
		
	var new_quest = quest_scene.instantiate() as Quest
	new_quest.quest_id = quest_id
	new_quest.quest_name = quest_resource.quest_title
	new_quest.quest_objectives = quest_resource.quest_objectives
	%Quests.add_child(new_quest)
	active_quests.append(new_quest)


func remove_quest(quest_id:QuestResource.QuestIds) -> void:
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


func is_on_quest(quest_id:QuestResource.QuestIds) -> bool:
	for quest:Quest in active_quests:
		if quest.quest_id == quest_id:
			return true
	return false


func print_active_quests() -> void:
	print("Printing Active Quests...")
	for quest:Quest in active_quests:
		print(quest.quest_data.name)
	print("End Print")


func update_quest_objective(quest_id:QuestResource.QuestIds, quest_objective:String) -> void:
	if not is_on_quest(quest_id):
		return
	var this_quest:Quest
	for quest:Quest in active_quests:
		if quest.quest_id == quest_id:
			for quest_obj:Quest.QuestObjective in quest.quest_data.objectives:
				if quest_obj.name == quest_objective and not quest_obj.status:
					quest_obj.status = true
					this_quest = quest
	if not this_quest:
		return
	for quest:Quest in %Quests.get_children():
		if quest.quest_id == quest_id:
			for quest_obj_label:RichTextLabel in quest.quest_objectives_vbox.get_children():
				var quest_obj:Quest.QuestObjective = quest.quest_data.get_quest_objective(quest_objective)
				if not quest_obj:
					continue
				var parsed_text = quest_obj_label.get_parsed_text()
				if parsed_text == quest_obj.name:
					quest_obj_label.text = "[font_size=14][outline_color=black][outline_size=3][color=green][s]%s[/s][/color][/outline_size][/outline_color][/font_size]" % quest_obj.name
	var is_quest_finished:bool = true
	for quest_obj:Quest.QuestObjective in this_quest.quest_data.objectives:
		if not quest_obj.status:
			is_quest_finished = false
			break
	if is_quest_finished:
		remove_quest(this_quest.quest_id)
		GlobalSignal.add_xp.emit(5)
		var next_quest:QuestResource.QuestIds = get_next_quest(this_quest.quest_id)
		if next_quest != QuestResource.QuestIds.NONE:
			add_quest(next_quest)

func get_next_quest(quest_id:QuestResource.QuestIds) -> QuestResource.QuestIds:
	match quest_id:
		QuestResource.QuestIds.BUY_INGREDIENTS:
			return QuestResource.QuestIds.MOVE_PRODUCTS
		QuestResource.QuestIds.MOVE_PRODUCTS:
			return QuestResource.QuestIds.MAKE_PIZZA
		QuestResource.QuestIds.MAKE_PIZZA:
			return QuestResource.QuestIds.PLACE_PIZZA
		QuestResource.QuestIds.PLACE_PIZZA:
			return QuestResource.QuestIds.BUY_TABLE
		QuestResource.QuestIds.BUY_TABLE:
			return QuestResource.QuestIds.CHANGE_STORE_NAME
		QuestResource.QuestIds.CHANGE_STORE_NAME:
			return QuestResource.QuestIds.OPEN_PIZZERIA
		QuestResource.QuestIds.OPEN_PIZZERIA:
			return QuestResource.QuestIds.SERVE_CUSTOMERS
		QuestResource.QuestIds.SERVE_CUSTOMERS:
			return QuestResource.QuestIds.CLOSE_PIZZERIA
		_:
			return QuestResource.QuestIds.NONE


func load_quests(path: String) -> void:
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	var ent_name = dir.get_next()
	while ent_name != "":
		var ent_path: String = path + "/" + ent_name
		if dir.current_is_dir():
			load_quests(ent_path)
		elif ent_name.ends_with(".tres"):
			var quest = load(ent_path)
			#print("Loaded quest " + ent_path)
			quests_db.append(quest)
		ent_name = dir.get_next()
