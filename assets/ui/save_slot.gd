extends MarginContainer

@export var save_slot := 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	var playerData: PlayerData
	if ResourceLoader.exists(GlobalVar.get_save_slot_by_id(save_slot)):
		playerData = ResourceLoader.load(GlobalVar.get_save_slot_by_id(save_slot))
	if playerData:
		%SlotName.text = "Save Slot " + str(save_slot)
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


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		GlobalVar.save_slot = save_slot
		get_tree().change_scene_to_file("res://environment/level_1.tscn")
