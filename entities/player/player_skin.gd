extends Node3D
class_name PlayerSkin

@onready var movement_state_machine_playback: AnimationNodeStateMachinePlayback = $PlayerDummy/AnimationTree.get("parameters/MovementStateMachine/playback")

@export var is_walking := false:
	set(value):
		if is_walking == value:
			return
		is_walking = value
		if is_walking:
			movement_state_machine_playback.travel("Walking_B")
		
@export var is_idle := true:
	set(value):
		if is_idle == value:
			return
		is_idle = value
		if is_idle:
			movement_state_machine_playback.travel("Idle")
			
@export var helmut: MeshInstance3D
@export var head: MeshInstance3D
@export var head_pivot: Node3D

func walk_animation() -> void:
	is_walking = true
	is_idle = false
	
func idle_animation() -> void:
	is_walking = false
	is_idle = true
