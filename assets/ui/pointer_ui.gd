extends Control

func _ready() -> void:
	GlobalSignal.toggle_pointer_ui.connect(_toggle_pointer_ui)
	hide()

func _toggle_pointer_ui() -> void:
	visible = not visible
