class_name QuestControl
extends Control

const quest_objective_scene:PackedScene = preload("uid://ds2eh5sxwh0wb")

@export var quest_decorator:QuestDecorator
@export var quest_objectives_vbox:VBoxContainer

var quest_data:QuestData
var quest_reward_money:int = 0
var quest_reward_xp:int = 0

func _ready() -> void:
	quest_data = QuestData.new(quest_decorator)
	%QuestName.text = quest_data.quest_decorator.wrapped_quest.quest_title
	quest_reward_money = quest_data.quest_decorator.wrapped_quest.quest_reward_money
	quest_reward_xp = quest_data.quest_decorator.wrapped_quest.quest_reward_xp
	for quest_obj:QuestObjective in quest_data.objectives:
		var label = quest_objective_scene.instantiate() as RichTextLabel
		label.bbcode_enabled = true
		label.text = "[font_size=14][outline_color=black][outline_size=3][color=yellow]%s[/color][/outline_size][/outline_color][/font_size]" % quest_obj.obj_name
		quest_objectives_vbox.add_child(label)


class QuestData:
	var objectives:Array[QuestObjective]
	var quest_decorator:QuestDecorator
	
	func _init(_quest_decorator:QuestDecorator) -> void:
		quest_decorator = _quest_decorator
		
		for obj in quest_decorator.wrapped_quest.quest_objectives:
			if quest_decorator.wrapped_quest.quest_type == Quest.QuestType.None:
				var obj_key:StringName = obj.keys().get(0)
				var obj_value:String = obj.values().get(0)
				var quest_objective:QuestObjective = QuestObjective.new(obj_key, obj_value)
				objectives.append(quest_objective)
			elif quest_decorator.wrapped_quest.quest_type == Quest.QuestType.Fetch:
				if quest_decorator is FetchQuest:
					var obj_key:StringName
					match quest_decorator.item:
						QuestItems.DOUGH:
							obj_key = QuestObjs.BRING_DOUGH
						QuestItems.TOMATO:
							obj_key = QuestObjs.BRING_TOMATO
						QuestItems.SPELLBOOK:
							obj_key = QuestObjs.BRING_SPELLBOOK
						QuestItems.COIN:
							obj_key = QuestObjs.BRING_COIN
						QuestItems.SWORD_1H:
							obj_key = QuestObjs.BRING_SWORD_1H
						QuestItems.DAGGER:
							obj_key = QuestObjs.BRING_DAGGER
						QuestItems.AXE_2H:
							obj_key = QuestObjs.BRING_AXE_2H
						_:
							continue
					if not obj_key:
						continue
					var obj_value = quest_decorator.wrapped_quest.quest_objectives.get(0).get(obj_key)
					var quest_objective:QuestObjective = QuestObjective.new(obj_key, obj_value)
					objectives.append(quest_objective)
			elif quest_decorator.wrapped_quest.quest_type == Quest.QuestType.Delivery:
				if quest_decorator is DeliveryQuest:
					var obj_key:StringName
					match quest_decorator.room_number:
						101:
							obj_key = QuestObjs.DELIVER_PACKAGE_101
						102:
							obj_key = QuestObjs.DELIVER_PACKAGE_102
						103:
							obj_key = QuestObjs.DELIVER_PACKAGE_103
						104:
							obj_key = QuestObjs.DELIVER_PACKAGE_104
						201:
							obj_key = QuestObjs.DELIVER_PACKAGE_201
						202:
							obj_key = QuestObjs.DELIVER_PACKAGE_202
						203:
							obj_key = QuestObjs.DELIVER_PACKAGE_203
						204:
							obj_key = QuestObjs.DELIVER_PACKAGE_204
						_:
							continue
					if not obj_key:
						continue
					var obj_value = quest_decorator.wrapped_quest.quest_objectives.get(0).get(obj_key)
					var quest_objective:QuestObjective = QuestObjective.new(obj_key, obj_value)
					objectives.append(quest_objective)
		
	func get_quest_objective(quest_objective:StringName) -> QuestObjective:
		for quest_obj:QuestObjective in objectives:
			if quest_obj.obj_id == quest_objective:
				return quest_obj
		return null
		
class QuestObjective:
	var obj_id:StringName
	var obj_name:StringName
	var status:bool
	
	func _init(_obj_id:StringName, _obj_name:String) -> void:
		obj_id = _obj_id
		obj_name = _obj_name
		status = false
