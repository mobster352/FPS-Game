extends MarginContainer

@export var save_slot := 1

func load_game_data() -> void:
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
	var foreground:ColorRect = get_node("/root/Node/CanvasLayer/Foreground")
	var tween = create_tween()
	tween.tween_property(foreground, "color:a", 1.0, 0)
	await tween.finished
	GlobalVar.save_slot = save_slot
	get_node("/root/Node/CanvasLayer/LoadGameMenu").hide()
	GlobalSignal.spawn_new_level.emit()


func _on_load_game_menu_visibility_changed() -> void:
	if visible:
		load_game_data()
