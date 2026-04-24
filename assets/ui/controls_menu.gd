extends Control

@export var pause_menu: Control
@export var menu_audio: AudioStreamPlayer

func _ready() -> void:
	$BackButton/TextureButton.grab_focus()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		hide()
		pause_menu.show()

func _on_back_button_pressed() -> void:
	hide()
	pause_menu.show()


func _on_texture_button_mouse_entered() -> void:
	menu_audio.play()


func _on_visibility_changed() -> void:
	if visible and is_inside_tree():
		$BackButton/TextureButton.grab_focus()
