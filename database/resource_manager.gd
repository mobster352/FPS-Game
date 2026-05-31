extends Node

var dialogue_db:Array
var quests_db:Array
var quest_dialogue_db:Array
var quest_objective_items:Array
var quest_room_numbers:Array

var fetch_quests:Dictionary[String, FetchQuest]
var mage_npc_fetch_quests:Dictionary[String, FetchQuest]
var knight_npc_fetch_quests:Dictionary[String, FetchQuest]
var rogue_npc_fetch_quests:Dictionary[String, FetchQuest]
var rogue_hooded_npc_fetch_quests:Dictionary[String, FetchQuest]
var barbarian_npc_fetch_quests:Dictionary[String, FetchQuest]
var dummy_npc_fetch_quests:Dictionary[String, FetchQuest]

var delivery_quests:Dictionary[String, DeliveryQuest]

func _ready() -> void:
	dialogue_db = load_resource("res://resources/dialogue")
	quests_db = load_resource("res://database/quests")
	quest_dialogue_db = load_resource("res://resources/quest_dialogue")
	quest_objective_items = load_resource("res://resources/quest_objective_items")
	quest_room_numbers = load_resource("res://resources/quest_room_numbers")
	create_fetch_quests()
	create_delivery_quests()
	
	#for q:QuestResource in quests_db:
		#print(q.quest_id)


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


func create_delivery_quests() -> void:
	for quest_resource:QuestResource in quests_db:
		if quest_resource.quest_type != Quest.QuestType.Delivery:
			continue
		for quest_objective:Dictionary in quest_resource.quest_objectives:
			for quest_room_number:QuestRoomNumber in quest_room_numbers:
				if quest_objective.has(quest_room_number.quest_objective_id):
					var quest_objective_id:StringName = quest_room_number.quest_objective_id
					var quest_item_mesh:StringName = quest_room_number.quest_item_mesh
					var room_number:int = quest_room_number.room_number
					delivery_quests.set(quest_objective_id, DeliveryQuest.new(quest_resource, room_number, quest_item_mesh))


func create_fetch_quests() -> void:
	for quest_resource:QuestResource in quests_db:
		if quest_resource.quest_type != Quest.QuestType.Fetch:
			continue
		for quest_objective:Dictionary in quest_resource.quest_objectives:
			for quest_objective_item:QuestObjectiveItem in quest_objective_items:
				if quest_objective.has(quest_objective_item.quest_objective_id):
					var quest_objective_id:StringName = quest_objective_item.quest_objective_id
					var quest_item_mesh:StringName = quest_objective_item.quest_item_mesh
					match quest_resource.npc_type:
						GlobalVar.NpcType.Any:
							if not fetch_quests.has(quest_objective_id):
								fetch_quests.set(quest_objective_id, FetchQuest.new(quest_resource, quest_item_mesh))
						GlobalVar.NpcType.Mage:
							if not mage_npc_fetch_quests.has(quest_objective_id):
								mage_npc_fetch_quests.set(quest_objective_id, FetchQuest.new(quest_resource, quest_item_mesh))
						GlobalVar.NpcType.Knight:
							if not knight_npc_fetch_quests.has(quest_objective_id):
								knight_npc_fetch_quests.set(quest_objective_id, FetchQuest.new(quest_resource, quest_item_mesh))
						GlobalVar.NpcType.Rogue:
							if not rogue_npc_fetch_quests.has(quest_objective_id):
								rogue_npc_fetch_quests.set(quest_objective_id, FetchQuest.new(quest_resource, quest_item_mesh))
						GlobalVar.NpcType.Rogue_Hooded:
							if not rogue_hooded_npc_fetch_quests.has(quest_objective_id):
								rogue_hooded_npc_fetch_quests.set(quest_objective_id, FetchQuest.new(quest_resource, quest_item_mesh))
						GlobalVar.NpcType.Barbarian:
							if not barbarian_npc_fetch_quests.has(quest_objective_id):
								barbarian_npc_fetch_quests.set(quest_objective_id, FetchQuest.new(quest_resource, quest_item_mesh))
						GlobalVar.NpcType.Default:
							if not dummy_npc_fetch_quests.has(quest_objective_id):
								dummy_npc_fetch_quests.set(quest_objective_id, FetchQuest.new(quest_resource, quest_item_mesh))


func get_random_fetch_quest(skin_uuid:String) -> Quest:
	if not GlobalVar.npc_skins.has(skin_uuid):
		push_error("NPC Skin not found: ", skin_uuid)
		return
	var npc_type:GlobalVar.NpcType = GlobalVar.npc_skins.get(skin_uuid)
	var random_quest_objective_id:StringName
	var fetch_quest:FetchQuest
	match npc_type:
		GlobalVar.NpcType.Any:
			random_quest_objective_id = fetch_quests.keys().pick_random()
			fetch_quest = fetch_quests.get(random_quest_objective_id)
		GlobalVar.NpcType.Mage:
			random_quest_objective_id = mage_npc_fetch_quests.keys().pick_random()
			fetch_quest = mage_npc_fetch_quests.get(random_quest_objective_id)
		GlobalVar.NpcType.Knight:
			random_quest_objective_id = knight_npc_fetch_quests.keys().pick_random()
			fetch_quest = knight_npc_fetch_quests.get(random_quest_objective_id)
		GlobalVar.NpcType.Rogue:
			random_quest_objective_id = rogue_npc_fetch_quests.keys().pick_random()
			fetch_quest = rogue_npc_fetch_quests.get(random_quest_objective_id)
		GlobalVar.NpcType.Rogue_Hooded:
			random_quest_objective_id = rogue_hooded_npc_fetch_quests.keys().pick_random()
			fetch_quest = rogue_hooded_npc_fetch_quests.get(random_quest_objective_id)
		GlobalVar.NpcType.Barbarian:
			random_quest_objective_id = barbarian_npc_fetch_quests.keys().pick_random()
			fetch_quest = barbarian_npc_fetch_quests.get(random_quest_objective_id)
		GlobalVar.NpcType.Default:
			random_quest_objective_id = dummy_npc_fetch_quests.keys().pick_random()
			fetch_quest = dummy_npc_fetch_quests.get(random_quest_objective_id)
		_:
			random_quest_objective_id = fetch_quests.keys().pick_random()
			fetch_quest = fetch_quests.get(random_quest_objective_id)
	if not random_quest_objective_id:
		push_error("Quest objective id not found: ", random_quest_objective_id)
		return
	if not fetch_quest:
		push_error("Fetch Quest not found: ", fetch_quest)
		return
	return get_quest_from_fetch_quest(random_quest_objective_id, fetch_quest)


func get_weapon_fetch_quest_for_character(skin_uuid:StringName) -> Quest:
	if not GlobalVar.npc_skins.has(skin_uuid):
		push_error("NPC Skin not found: ", skin_uuid)
		return
	var npc_type:GlobalVar.NpcType = GlobalVar.npc_skins.get(skin_uuid)
	var quest_objective_id:StringName
	var fetch_quest:FetchQuest
	match npc_type:
		GlobalVar.NpcType.Mage:
			quest_objective_id = QuestObjs.BRING_SPELLBOOK
			fetch_quest = mage_npc_fetch_quests.get(quest_objective_id)
		GlobalVar.NpcType.Knight:
			quest_objective_id = QuestObjs.BRING_SWORD_1H
			fetch_quest = knight_npc_fetch_quests.get(quest_objective_id)
		GlobalVar.NpcType.Rogue:
			quest_objective_id = QuestObjs.BRING_DAGGER
			fetch_quest = rogue_npc_fetch_quests.get(quest_objective_id)
		GlobalVar.NpcType.Rogue_Hooded:
			quest_objective_id = QuestObjs.BRING_DAGGER
			fetch_quest = rogue_hooded_npc_fetch_quests.get(quest_objective_id)
		GlobalVar.NpcType.Barbarian:
			quest_objective_id = QuestObjs.BRING_AXE_2H
			fetch_quest = barbarian_npc_fetch_quests.get(quest_objective_id)
		GlobalVar.NpcType.Default:
			quest_objective_id = QuestObjs.BRING_COIN
			fetch_quest = dummy_npc_fetch_quests.get(quest_objective_id)
	if not fetch_quest:
		push_error("Fetch Quest not found: ", fetch_quest)
		return
	return get_quest_from_fetch_quest(quest_objective_id, fetch_quest)


func get_random_delivery_quest() -> Array:
	var random_delivery_quest:StringName = delivery_quests.keys().pick_random()
	var delivery_quest:DeliveryQuest = delivery_quests.get(random_delivery_quest)
	return [Quest.new(delivery_quest.wrapped_quest.quest_id, random_delivery_quest, QuestItems.PACKAGE), delivery_quest.room_number]


func get_delivery_quest(quest_objective_id:StringName) -> DeliveryQuest:
	if delivery_quests.has(quest_objective_id):
		return delivery_quests.get(quest_objective_id)
	push_error("Quest objective id not found: ", quest_objective_id)
	return null


func get_quest_from_fetch_quest(quest_objective_id:StringName, fetch_quest:FetchQuest) -> Quest:
	var quest_id:StringName = fetch_quest.wrapped_quest.quest_id
	var quest_item_id:StringName = fetch_quest.item
	var quest:Quest = Quest.new(quest_id, quest_objective_id, quest_item_id)
	return quest


func get_fetch_quest(quest_objective_id:StringName) -> FetchQuest:
	if fetch_quests.has(quest_objective_id):
		return fetch_quests.get(quest_objective_id)
	if mage_npc_fetch_quests.has(quest_objective_id):
		return mage_npc_fetch_quests.get(quest_objective_id)
	if knight_npc_fetch_quests.has(quest_objective_id):
		return knight_npc_fetch_quests.get(quest_objective_id)
	if rogue_npc_fetch_quests.has(quest_objective_id):
		return rogue_npc_fetch_quests.get(quest_objective_id)
	if rogue_hooded_npc_fetch_quests.has(quest_objective_id):
		return rogue_hooded_npc_fetch_quests.get(quest_objective_id)
	if barbarian_npc_fetch_quests.has(quest_objective_id):
		return barbarian_npc_fetch_quests.get(quest_objective_id)
	if dummy_npc_fetch_quests.has(quest_objective_id):
		return dummy_npc_fetch_quests.get(quest_objective_id)
	push_error("Quest objective id not found: ", quest_objective_id)
	return null


func load_resource(path: String) -> Array:
	var resource_array:Array
	var dir = ResourceLoader.list_directory(path)
	for ent_name in dir:
		if ent_name.ends_with(".tres"):
			var ent_path: String = path + "/" + ent_name
			var res = load(ent_path)
			resource_array.append(res)
	return resource_array
