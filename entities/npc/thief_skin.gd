extends Node3D
class_name ThiefSkin

@onready var animation_tree: AnimationTree
@onready var movement_state_machine: AnimationNodeStateMachinePlayback

func _ready() -> void:
	animation_tree = $"../AnimationTree"
	movement_state_machine = animation_tree.get("parameters/MovementStateMachine/playback")
	
func idle_animation() -> void:
	movement_state_machine.travel("Idle")
	

func idle_hold_large_object_animation() -> void:
	movement_state_machine.travel("Idle_HoldLargeObject")

func walk_animation() -> void:
	movement_state_machine.travel("Walking_B")
	
func walk_hold_large_object_animation() -> void:
	movement_state_machine.travel("Walking_HoldLargeObject")

func hit_animation() -> void:
	animation_tree.set("parameters/HitOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
