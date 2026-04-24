extends Control

@export var rolling_pin_button:Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rolling_pin_button.grab_focus()
	

func _on_visibility_changed() -> void:
	if is_inside_tree():
		rolling_pin_button.grab_focus()
