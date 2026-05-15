class_name Quest
extends Control

const quest_objective_scene:PackedScene = preload("uid://ds2eh5sxwh0wb")

@export var quest_id:StringName
@export var quest_name:StringName
@export var quest_objectives:Array[Dictionary]
@export var quest_objectives_vbox:VBoxContainer

var quest_data:QuestData

func _ready() -> void:
	quest_data = QuestData.new()
	quest_data = quest_data.create_quest_data(quest_id, quest_name, quest_objectives)
	%QuestName.text = quest_data.quest_name
	for quest_obj:QuestObjective in quest_data.objectives:
		var label = quest_objective_scene.instantiate() as RichTextLabel
		label.bbcode_enabled = true
		label.text = "[font_size=14][outline_color=black][outline_size=3][color=yellow]%s[/color][/outline_size][/outline_color][/font_size]" % quest_obj.obj_name
		quest_objectives_vbox.add_child(label)



class QuestData:
	var quest_id:StringName
	var quest_name:StringName
	var objectives:Array[QuestObjective]
	
	func create_quest_data(_quest_id:StringName, _quest_name:StringName, _quest_objectives:Array[Dictionary]) -> QuestData:
		quest_id = _quest_id
		quest_name = _quest_name
		
		for obj in _quest_objectives:
			var obj_key:StringName = obj.keys().get(0)
			var obj_value:String = obj.values().get(0)
			var quest_objective:QuestObjective = QuestObjective.new()
			objectives.append(quest_objective.create_quest_objective(obj_key, obj_value))
		return self
		
	func get_quest_objective(quest_objective:StringName) -> QuestObjective:
		for quest_obj:QuestObjective in objectives:
			if quest_obj.obj_id == quest_objective:
				return quest_obj
		return null
		
class QuestObjective:
	var obj_id:StringName
	var obj_name:StringName
	var status:bool
	
	func create_quest_objective(_obj_id:StringName, _obj_name:String) -> QuestObjective:
		obj_id = _obj_id
		obj_name = _obj_name
		status = false
		return self
