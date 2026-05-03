extends MarginContainer

@export var save_slot := 1

const LEVEL_1 = preload("res://environment/level_1.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	var playerData: PlayerData
	if ResourceLoader.exists(GlobalVar.get_save_slot_by_id(save_slot)):
		playerData = ResourceLoader.load(GlobalVar.get_save_slot_by_id(save_slot))
	if playerData:
		%SlotName.text = "Save Slot " + str(save_slot)
		if playerData.store_name:
			%StoreName.show()
			%StoreName.text = playerData.store_name
		%MoneyContainer.show()
		%MoneyValue.text = str(playerData.money)
		%Date.show()
		%Date.text = \
			str(playerData.save_date.get("month")) + "/" + \
			str(playerData.save_date.get("day")) + "/" + \
			str(playerData.save_date.get("year")) + " " + \
			str(playerData.save_date.get("hour")) + ":" + \
			str(playerData.save_date.get("minute")) + ":" + \
			str(playerData.save_date.get("second"))
		%DayContainer.show()
		%DayValue.text = str(playerData.day)


func delete_slot() -> void:
	%SlotName.text = "Empty Save Slot"
	%StoreName.hide()
	%MoneyContainer.hide()
	%Date.hide()
	%DayContainer.hide()


func _on_button_pressed() -> void:
	GlobalVar.save_slot = save_slot
	#get_tree().change_scene_to_file("res://environment/level_1.tscn")
	var level_node:Node3D = LEVEL_1.instantiate()
	level_node.name = "Level"
	get_node("/root/Game").add_child(level_node)
	get_node("/root/Game/LoadGameMenu").hide()
