class_name Quest
extends Control

const quest_objective_scene:PackedScene = preload("uid://ds2eh5sxwh0wb")

@export var quest_id:QuestResource.QuestIds
@export var quest_objectives:VBoxContainer

var quest_data:QuestResource.QuestData

func _ready() -> void:
	quest_data = QuestResource.QuestData.new()
	quest_data = quest_data.create_quest_data(quest_id)
	%QuestName.text = quest_data.name
	for quest_obj:QuestResource.QuestObjective in quest_data.objectives:
		var label = quest_objective_scene.instantiate() as RichTextLabel
		label.bbcode_enabled = true
		label.text = "[font_size=14][color=yellow]%s[/color][/font_size]" % quest_obj.name
		quest_objectives.add_child(label)
