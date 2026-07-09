extends Label

func _ready() -> void:
	GlobalSignal.update_input_device.connect(_update_input_device)
	
func _update_input_device(input_device:GlobalVar.InputDevice) -> void:
	if input_device == GlobalVar.InputDevice.MOUSE_KEYBOARD:
		text = "Space - Confirm Transaction"
	else:
		text = "A - Confirm Transaction"
