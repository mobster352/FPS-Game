extends Control
class_name ActionInput

@export var action: Action:
	set(value):
		action = value
		if label:
			label.text = get_text_from_action()

@export var input_button:InputButton

@onready var label: Label = %Label
@onready var texture_rect: TextureRect = %TextureRect

enum Action {
	None,
	PickUp,
	PickOne,
	Place,
	Drop,
	Interact,
	Cook,
	OpenLid,
	Confirm,
	Cancel,
	Move,
	Sell,
	PutBack,
	Combine
}

enum InputButton {
	LEFT,
	RIGHT,
	COOK
}

func _ready() -> void:
	label.text = get_text_from_action()

func get_text_from_action() -> StringName:
	if action == Action.PickUp:
		return "Pick Up"
	elif action == Action.PickOne:
		return "Pick One"
	elif action == Action.Place:
		return "Place"
	elif action == Action.Drop:
		return "Drop"
	elif action == Action.Interact:
		return "Interact"
	elif action == Action.Cook:
		return "Cook"
	elif action == Action.OpenLid:
		return "Open Lid"
	elif action == Action.Confirm:
		return "Confirm"
	elif action == Action.Cancel:
		return "Cancel"
	elif action == Action.Move:
		return "Move"
	elif action == Action.Sell:
		return "Sell"
	elif action == Action.PutBack:
		return "Put Back"
	elif action == Action.Combine:
		return "Combine"
	else:
		return "N/A"


func update_input_textures(input_type:InputsUI.InputType) -> void:
	if input_button == InputButton.LEFT:
		if input_type == InputsUI.InputType.MOUSE:
			texture_rect.texture = load("res://assets/ui/tile_0077.png")
		elif input_type == InputsUI.InputType.CONTROLLER:
			texture_rect.texture = load("res://assets/ui/tile_0008.png")
	elif input_button == InputButton.RIGHT:
		if input_type == InputsUI.InputType.MOUSE:
			texture_rect.texture = load("res://assets/ui/tile_0078.png")
		elif input_type == InputsUI.InputType.CONTROLLER:
			texture_rect.texture = load("res://assets/ui/tile_0009.png")
	elif input_button == InputButton.COOK:
		if input_type == InputsUI.InputType.MOUSE:
			texture_rect.texture = load("res://assets/ui/tile_0087.png")
		elif input_type == InputsUI.InputType.CONTROLLER:
			texture_rect.texture = load("res://assets/ui/tile_0011.png")
