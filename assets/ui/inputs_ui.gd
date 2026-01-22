extends Control
class_name InputsUI

@export var left_input: ActionInput
@export var right_input: ActionInput
@export var cook_input: ActionInput

@warning_ignore("unused_signal")
signal update_actions(input_action:InputAction)

enum InputAction {
	None,
	Interact,
	InteractItem,
	Cook,
	OpenLid
}

func _ready() -> void:
	update_actions.connect(_update_actions)
	
func _update_actions(input_action:InputAction, has_held_object:bool = false, can_place:bool = false, has_count:bool = false) -> void:
	if input_action == InputAction.InteractItem:
		cook_input.hide()
		if has_held_object:
			if can_place:
				left_input.action = ActionInput.Action.Place
				right_input.action = ActionInput.Action.Drop
				left_input.show()
				right_input.show()
			else:
				left_input.action = ActionInput.Action.PickUp
				right_input.action = ActionInput.Action.Drop
				left_input.show()
				right_input.show()
		else:
			left_input.action = ActionInput.Action.PickUp
			left_input.show()
			right_input.hide()
		if has_count:
			left_input.action = ActionInput.Action.PickOne
			left_input.show()
			right_input.action = ActionInput.Action.PickUp
			right_input.show()
	elif input_action == InputAction.Interact:
		left_input.action = ActionInput.Action.Interact
		left_input.show()
		if has_held_object:
			right_input.action = ActionInput.Action.Drop
			right_input.show()
		else:
			right_input.hide()
	elif input_action == InputAction.Cook:
		cook_input.action = ActionInput.Action.Cook
		cook_input.show()
		if has_held_object:
			left_input.action = ActionInput.Action.PickUp
			left_input.show()
			right_input.action = ActionInput.Action.Drop
			right_input.show()
		else:
			left_input.hide()
			right_input.hide()
	elif input_action == InputAction.OpenLid:
		cook_input.action = ActionInput.Action.OpenLid
		cook_input.show()
		if has_held_object:
			left_input.action = ActionInput.Action.PickUp
			left_input.show()
			right_input.action = ActionInput.Action.Drop
			right_input.show()
		else:
			left_input.action = ActionInput.Action.PickUp
			left_input.show()
			right_input.hide()
	else:
		cook_input.hide()
		if has_held_object:
			if can_place:
				left_input.action = ActionInput.Action.Place
				right_input.action = ActionInput.Action.Drop
				left_input.show()
				right_input.show()
			else:
				right_input.action = ActionInput.Action.Drop
				left_input.hide()
				right_input.show()
		else:
			left_input.hide()
			right_input.hide()
