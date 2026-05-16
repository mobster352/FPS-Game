class_name QuestLog
extends Control

const quest_scene:PackedScene = preload("uid://b3utve62uqxuv")

var active_quests:Array[Quest]

var quests_db:Array[QuestResource]

var player:Player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	GlobalSignal.add_quest.connect(_add_quest)
	GlobalSignal.update_quest_objective.connect(_update_quest_objective)
	load_quests("res://database/quests")


func get_quest_resource_from_db(quest_id:StringName,  item_mesh_name="") -> QuestDecorator:
	for quest:QuestResource in quests_db:
		if quest.quest_id == quest_id:
			match quest.quest_type:
				Quest.QuestType.None:
					return QuestDecorator.new(quest)
				Quest.QuestType.Fetch:
					return FetchQuest.new(quest, item_mesh_name)
	return null


func _add_quest(quest_id:StringName, item_mesh_name="") -> void:
	if is_on_quest(quest_id):
		return
		
	var quest_decorator:QuestDecorator = get_quest_resource_from_db(quest_id, item_mesh_name)
	
	if not quest_decorator:
		push_error("Quest not found during add_quest: ", quest_id)
		return
	
	var new_quest = quest_scene.instantiate() as Quest
	new_quest.quest_decorator = quest_decorator
	%Quests.add_child(new_quest)
	active_quests.append(new_quest)


func remove_quest(quest_id:StringName) -> void:
	var index:int = 0
	for quest:Quest in active_quests:
		if quest.quest_decorator.wrapped_quest.quest_id == quest_id:
			active_quests.remove_at(index)
			break
		index += 1
	for quest:Quest in %Quests.get_children():
		if quest.quest_decorator.wrapped_quest.quest_id == quest_id:
			%Quests.remove_child(quest)
			break


func is_on_quest(quest_id:StringName) -> bool:
	for quest:Quest in active_quests:
		if quest.quest_decorator.wrapped_quest.quest_id == quest_id:
			return true
	return false


func print_active_quests() -> void:
	print("Printing Active Quests...")
	for quest:Quest in active_quests:
		print(quest.quest_data.quest_decorator.wrapped_quest.quest_title)
	print("End Print")


func _update_quest_objective(quest_id:StringName, quest_objective_id:StringName) -> void:
	if not is_on_quest(quest_id):
		return
	
	var this_quest:Quest
	for quest:Quest in active_quests:
		if quest.quest_decorator.wrapped_quest.quest_id == quest_id:
			var quest_decorator = quest.quest_decorator
			if quest_decorator is FetchQuest:
				var item = quest_decorator.item
				if not player:
					return
				if not player.has_held_object():
					return
				if player.get_held_object_mesh_name() != item:
					return
				player.delete_held_object()
			elif quest_decorator is QuestDecorator:
				pass
			else:
				return
			for quest_obj:Quest.QuestObjective in quest.quest_data.objectives:
				if quest_obj.obj_id == quest_objective_id and not quest_obj.status:
					quest_obj.status = true
					this_quest = quest
					break
			break
	if not this_quest:
		return
	for quest:Quest in %Quests.get_children():
		if quest.quest_decorator.wrapped_quest.quest_id == quest_id:
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
		remove_quest(this_quest.quest_decorator.wrapped_quest.quest_id)
		GlobalSignal.add_xp.emit(5)
		var next_quest:StringName = get_next_quest(this_quest.quest_decorator.wrapped_quest.quest_id)
		if next_quest != "":
			_add_quest(next_quest)

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
