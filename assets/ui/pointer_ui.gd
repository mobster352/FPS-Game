extends Control

func _ready() -> void:
	GlobalSignal.toggle_pointer_ui.connect(_toggle_pointer_ui)

func _toggle_pointer_ui() -> void:
	visible = not visible
