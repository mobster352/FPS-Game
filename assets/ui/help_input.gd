extends Control

@export var help_text:String
#@export var help_button_mk:String:
	#set(value):
		#help_button_mk = value
		#%HelpButton.text = value
#@export var help_button_ctr:String:
	#set(value):
		#help_button_ctr = value
		#%HelpButton.text = value
@export var action_texture_mk:Texture2D
@export var action_texture_mk_2:Texture2D
@export var action_texture_ctr:Texture2D
@onready var action_texture_rect: TextureRect = %ActionTextureRect
@onready var action_texture_rect_2: TextureRect = %ActionTextureRect2


func _ready() -> void:
	%HelpText.text = help_text
	action_texture_rect.texture = action_texture_mk
	action_texture_rect_2.texture = action_texture_mk_2
	GlobalSignal.update_input_device.connect(_update_input_device)

func _update_input_device(input_device: GlobalVar.InputDevice) -> void:
	if input_device == GlobalVar.InputDevice.MOUSE_KEYBOARD:
		#%HelpButton.text = help_button_mk
		action_texture_rect.texture = action_texture_mk
		action_texture_rect_2.texture = action_texture_mk_2
		action_texture_rect_2.show()
	else:
		#%HelpButton.text = help_button_ctr
		action_texture_rect.texture = action_texture_ctr
		action_texture_rect_2.hide()
