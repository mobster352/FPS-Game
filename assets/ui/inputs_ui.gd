extends Control
class_name InputsUI

@export var left_input: ActionInput
@export var right_input: ActionInput
@export var cook_input: ActionInput
@export var input_type:InputType:
	set(value):
		input_type = value
		left_input.update_input_textures(value)
		right_input.update_input_textures(value)
		cook_input.update_input_textures(value)

@warning_ignore("unused_signal")
signal update_actions(input_action:InputAction)

enum InputAction {
	None,
	Interact,
	InteractItem,
	Cook,
	OpenLid,
	Place,
	PrePlacement,
	OnlyPlacement,
	PreMove,
	Confirm,
	CombineStack,
	PutBack,
	Default
}

enum InputType {
	MOUSE,
	CONTROLLER
}


func _ready() -> void:
	update_actions.connect(_update_actions)
	
func _update_actions(input_action:InputAction, has_held_object:bool = false, has_count:bool = false, peer_id:int = 1) -> void:
	if multiplayer.get_unique_id() != peer_id:
		return
	match input_action:
		InputAction.Interact:
			interact(has_held_object)
		InputAction.InteractItem:
			interact_item(has_held_object, has_count)
		InputAction.Cook:
			cook(has_held_object)
		InputAction.OpenLid:
			open_lid(has_held_object)
		InputAction.PrePlacement:
			pre_placement()
		InputAction.OnlyPlacement:
			only_placement()
		InputAction.PreMove:
			pre_move()
		InputAction.Confirm:
			confirm()
		InputAction.CombineStack:
			combine_stack()
		InputAction.PutBack:
			put_back()
		_:
			default(has_held_object)
	
func interact(has_held_object:bool) -> void:
	left_input.action = ActionInput.Action.Interact
	left_input.show()
	if has_held_object:
		right_input.action = ActionInput.Action.Drop
		right_input.show()
	else:
		right_input.hide()

	
func interact_item(has_held_object:bool, has_count:bool) -> void:
	cook_input.hide()
	if has_held_object:
		left_input.action = ActionInput.Action.PickUp
		right_input.action = ActionInput.Action.Drop
		left_input.show()
		right_input.show()
	else:
		left_input.action = ActionInput.Action.PickUp
		left_input.show()
		right_input.hide()
	if has_count:
		if has_held_object:
			left_input.action = ActionInput.Action.PutBack
			right_input.action = ActionInput.Action.Drop
			left_input.show()
			right_input.show()
		else:
			left_input.action = ActionInput.Action.PickOne
			left_input.show()
			right_input.action = ActionInput.Action.PickUp
			right_input.show()

func combine_stack() -> void:
	cook_input.hide()
	cook_input.hide()
	left_input.action = ActionInput.Action.Combine
	left_input.show()
	right_input.hide()
	
func put_back() -> void:
	cook_input.hide()
	cook_input.hide()
	left_input.action = ActionInput.Action.PutBack
	left_input.show()
	right_input.hide()

func cook(has_held_object:bool) -> void:
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


func open_lid(has_held_object:bool) -> void:
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
	
	
func confirm() -> void:
	cook_input.hide()
	left_input.action = ActionInput.Action.Confirm
	left_input.show()
	right_input.action = ActionInput.Action.Cancel
	right_input.show()
	
func pre_placement() -> void:
	left_input.action = ActionInput.Action.Place
	right_input.action = ActionInput.Action.Drop
	left_input.show()
	right_input.show()
	
func only_placement() -> void:
	left_input.action = ActionInput.Action.Place
	left_input.show()
	right_input.hide()
	
func pre_move() -> void:
	left_input.action = ActionInput.Action.Move
	left_input.show()
	right_input.action = ActionInput.Action.Sell
	right_input.show()


func default(has_held_object:bool) -> void:
	cook_input.hide()
	if has_held_object:
		right_input.action = ActionInput.Action.Drop
		left_input.hide()
		right_input.show()
	else:
		left_input.hide()
		right_input.hide()
