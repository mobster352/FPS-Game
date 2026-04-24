extends Control

@export var name_input: LineEdit
@export var size_input: SpinBox
@export var billboard_label: Label3D
@export var back_button: TextureButton

@onready var player: Player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	name_input.text = billboard_label.text
	size_input.value = billboard_label.font_size
	GlobalSignal.update_store_name.connect(_update_store_name)
	name_input.focus_neighbor_bottom = size_input.get_line_edit().get_path()
	back_button.focus_neighbor_top = size_input.get_line_edit().get_path()

func _on_save_button_pressed() -> void:
	get_tree().paused = false
	GlobalSignal.update_store_name.emit(billboard_label.text, billboard_label.font_size)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hide()
	player.freeze_camera = false


func _on_size_input_value_changed(value: float) -> void:
	size_input.value = value
	billboard_label.font_size = int(value)


func _on_name_input_text_changed(new_text: String) -> void:
	name_input.text = new_text
	name_input.caret_column = new_text.length()
	billboard_label.text = new_text


func _update_store_name(store_name:String, font_size:int) -> void:
	billboard_label.text = store_name
	name_input.text = store_name
	name_input.caret_column = store_name.length()
	billboard_label.font_size = font_size
	size_input.value = font_size


func _on_visibility_changed() -> void:
	if visible:
		name_input.grab_focus()


#func _on_name_input_editing_toggled(toggled_on: bool) -> void:
	#if toggled_on:
		#DisplayServer.virtual_keyboard_show(name_input.text)
