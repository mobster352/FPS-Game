extends MarginContainer

@export var button_label: StringName
@export var normal_texture: Texture2D
@export var pressed_texture: Texture2D
@export var label: Label
@export var button: TextureButton

func _ready() -> void:
	label.text = button_label
	button.texture_normal = normal_texture
	button.texture_pressed = pressed_texture
