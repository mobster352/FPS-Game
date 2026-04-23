class_name QuestLog
extends Control

const quest_objective_scene:PackedScene = preload("uid://ds2eh5sxwh0wb")

var quests_data:Array[Quest.QuestData]

var player:Player

var active_quest_id:int:
	set(value):
		active_quest_id = value
		#await get_tree().create_timer(1.0).timeout
		update_quest_text()

func _ready() -> void:
	for id:int in Quest.QuestIds.values():
		var quest_data:Quest.QuestData = Quest.QuestData.new()
		quest_data = quest_data.create_quest_data(id)
		quests_data.append(quest_data)
	
	active_quest_id = Quest.QuestIds.BUY_INGREDIENTS
	player = get_tree().get_first_node_in_group("player")
	
func _process(_delta: float) -> void:
	if not visible:
		if player.playerData.day == 1:
			show()
		else:
			queue_free()

func update_quest_text() -> void:
	if quests_data.size() > active_quest_id:
		show()
		var quest_data:Quest.QuestData = get_quest_data_by_id(active_quest_id)
		if not quest_data:
			hide()
			return
		%Title.text = quest_data.name
		for child in %ObjectivesList.get_children():
			child.queue_free()
		for obj in quest_data.objectives:
			var label = quest_objective_scene.instantiate() as Label
			label.text = obj.name
			%ObjectivesList.add_child(label)
	else:
		hide()
		

func update_quest(quest_id:int) -> void:
	if active_quest_id != quest_id:
		return
	active_quest_id += 1


func get_quest_data_by_id(quest_id:int) -> Quest.QuestData:
	for quest_data:Quest.QuestData in quests_data:
		if quest_data.id == quest_id:
			return quest_data
	return null


func update_quest_objective(quest_objective_id:int) -> void:
	var quest_data:Quest.QuestData = get_quest_data_by_id(active_quest_id)
	if not quest_data:
		return
	for obj:Quest.QuestObjective in quest_data.objectives:
		if not obj:
			continue
		if obj.id != quest_objective_id:
			continue
		if obj.status:
			continue
		for child:Label in %ObjectivesList.get_children():
			if not child:
				continue
			if child.text == obj.name:
				child.free()
				if %ObjectivesList.get_child_count() <= 0:
					update_quest(active_quest_id)
				GlobalSignal.add_xp.emit(5)
				obj.status = true
