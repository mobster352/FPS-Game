extends Node3D
class_name ThiefSkin

@onready var movement_state_machine: AnimationNodeStateMachinePlayback

func _ready() -> void:
	movement_state_machine = $"../AnimationTree".get("parameters/MovementStateMachine/playback")
	
func idle_animation() -> void:
	movement_state_machine.travel("Idle")

func idle_hold_large_object_animation() -> void:
	movement_state_machine.travel("Idle_HoldLargeObject")

func walk_animation() -> void:
	movement_state_machine.travel("Walking_B")
	
func walk_hold_large_object_animation() -> void:
	movement_state_machine.travel("Walking_HoldLargeObject")
