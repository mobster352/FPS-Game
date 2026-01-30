extends Control
class_name ActionInput

@export var action: Action:
	set(value):
		action = value
		label.text = get_text_from_action()
@export var action_texture: Texture2D

@export var label: Label
@export var texture_rect: TextureRect

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
	Move
}

func _ready() -> void:
	label.text = get_text_from_action()
	texture_rect.texture = action_texture

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
	else:
		return "N/A"
