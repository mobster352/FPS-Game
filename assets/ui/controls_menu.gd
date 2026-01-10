extends Control

@export var pause_menu: Control

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		hide()
		pause_menu.show()

func _on_back_button_pressed() -> void:
	hide()
	pause_menu.show()
