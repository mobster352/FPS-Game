extends Control

@export var help_text:String
@export var controller_icon_texture:ControllerIconTexture
@onready var input_texture_rect: TextureRect = %InputTextureRect

func _ready() -> void:
	%HelpText.text = help_text
	input_texture_rect.texture = controller_icon_texture
