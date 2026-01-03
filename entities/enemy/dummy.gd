extends Node3D
class_name Dummy

@export var animationTree: AnimationTree
@export var animationPlayer: AnimationPlayer
@onready var animation_state_machine: AnimationNodeStateMachinePlayback

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_state_machine = animationTree.get("parameters/MovementStateMachine/playback")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func hit_animation() -> void:
	animationTree.set("parameters/HitOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func death_animation() -> void:
	animationPlayer.stop()
	animation_state_machine.travel("Death_A")


func shoot_animation() -> void:
	animationTree.set("parameters/ShootOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func aiming_animation() -> void:
	animation_state_machine.travel("1H_Ranged_Aiming")


func idle_animation() -> void:
	animation_state_machine.travel("Idle")
