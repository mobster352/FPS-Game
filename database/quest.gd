class_name Quest
extends Control

const quest_objective_scene:PackedScene = preload("uid://ds2eh5sxwh0wb")

@export var quest_id:QuestResource.QuestIds
@export var quest_name:String
@export var quest_objectives:Array[String]
@export var quest_objectives_vbox:VBoxContainer

var quest_data:QuestData

func _ready() -> void:
	quest_data = QuestData.new()
	quest_data = quest_data.create_quest_data(quest_id, quest_name, quest_objectives)
	%QuestName.text = quest_data.name
	for quest_obj:QuestObjective in quest_data.objectives:
		var label = quest_objective_scene.instantiate() as RichTextLabel
		label.bbcode_enabled = true
		label.text = "[font_size=14][outline_color=black][outline_size=3][color=yellow]%s[/color][/outline_size][/outline_color][/font_size]" % quest_obj.name
		quest_objectives_vbox.add_child(label)



class QuestData:
	var id:int
	var name:String
	var objectives:Array[QuestObjective]
	
	func create_quest_data(_id:int, _quest_name:String, _quest_objectives:Array[String]) -> QuestData:
		id = _id
		name = _quest_name
		for obj in _quest_objectives:
			var quest_objective:QuestObjective = QuestObjective.new()
			objectives.append(quest_objective.create_quest_objective(obj))
		return self
		
	func get_quest_objective(quest_objective:String) -> QuestObjective:
		for quest_obj:QuestObjective in objectives:
			if quest_obj.name == quest_objective:
				return quest_obj
		return null
		
class QuestObjective:
	var name:String
	var status:bool
	
	func create_quest_objective(_obj:String) -> QuestObjective:
		name = _obj
		status = false
		return self
