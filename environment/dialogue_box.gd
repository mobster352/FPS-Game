extends Node3D
class_name DialogueBox

@export var text: StringName
@onready var label = $CSGBox3D/SubViewport/Control/MarginContainer/Label
@onready var display_timer = $Timers/DisplayTimer


func _on_visibility_changed() -> void:
	if visible:
		label.text = text
		display_timer.start()


func _on_display_timer_timeout() -> void:
	hide()

func get_order_text() -> StringName:
	return "I want a "

func get_good_order_delivered_text() -> StringName:
	return "PIZZAAAA"
	
func get_bad_order_delivered_text() -> StringName:
	return "I didn't order that"
