extends Label

@onready var texture_rect_ctr: TextureRect = %TextureRectCtr
@onready var texture_rect_mk_1: TextureRect = %TextureRectMk_1
@onready var texture_rect_mk_2: TextureRect = %TextureRectMk_2
@onready var texture_rect_mk_3: TextureRect = %TextureRectMk_3

func _ready() -> void:
	GlobalSignal.update_input_device.connect(_update_input_device)
	
func _update_input_device(input_device:GlobalVar.InputDevice) -> void:
	if input_device == GlobalVar.InputDevice.MOUSE_KEYBOARD:
		texture_rect_mk_1.show()
		texture_rect_mk_2.show()
		texture_rect_mk_3.show()
		texture_rect_ctr.hide()
	else:
		texture_rect_ctr.show()
		texture_rect_mk_1.hide()
		texture_rect_mk_2.hide()
		texture_rect_mk_3.hide()
