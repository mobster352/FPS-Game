extends Control
class_name ErrorUI

@export var label_text: String:
	set(t):
		label_text = t
		$Label.text = t


func _on_button_pressed() -> void:
	queue_free()
