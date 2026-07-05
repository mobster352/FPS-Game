extends Control

@export var help_text:String
@export var help_button_mk:String:
	set(value):
		help_button_mk = value
		%HelpButton.text = value
@export var help_button_ctr:String:
	set(value):
		help_button_ctr = value
		%HelpButton.text = value


func _ready() -> void:
	%HelpText.text = help_text
	GlobalSignal.update_input_device.connect(_update_input_device)

func _update_input_device(input_device: GlobalVar.InputDevice) -> void:
	if input_device == GlobalVar.InputDevice.MOUSE_KEYBOARD:
		%HelpButton.text = help_button_mk
	else:
		%HelpButton.text = help_button_ctr
