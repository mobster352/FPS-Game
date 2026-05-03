extends Control

signal show_main_menu

func _ready() -> void:
	if ResourceLoader.exists(GlobalVar.get_save_slot_by_id(1)):
		%DeleteSlot1.show()
	if ResourceLoader.exists(GlobalVar.get_save_slot_by_id(2)):
		%DeleteSlot2.show()
	if ResourceLoader.exists(GlobalVar.get_save_slot_by_id(3)):
		%DeleteSlot3.show()
	$Slots/HBoxContainer/SaveSlot/PanelContainer/Button.grab_focus()

func _on_back_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://assets/ui/main_menu.tscn")
	hide()
	show_main_menu.emit()


func _on_delete_button_slot_1_pressed() -> void:
	delete_save_slot(1)
	%SaveSlot.delete_slot()


func _on_delete_button_slot_2_pressed() -> void:
	delete_save_slot(2)
	%SaveSlot2.delete_slot()


func _on_delete_button_slot_3_pressed() -> void:
	delete_save_slot(3)
	%SaveSlot3.delete_slot()


func delete_save_slot(slot_id:int) -> void:
	var path = GlobalVar.get_save_slot_by_id(slot_id)
	if FileAccess.file_exists(path):
		var error = DirAccess.remove_absolute(path)
		if error != OK:
			print("Error deleting save slot " + str(slot_id))


func _on_visibility_changed() -> void:
	if visible and $Slots/HBoxContainer/SaveSlot/PanelContainer/Button.is_inside_tree():
		$Slots/HBoxContainer/SaveSlot/PanelContainer/Button.grab_focus()


func _on_main_menu_show_load_game_menu() -> void:
	show()
