extends Node3D
class_name Dummy

@export var animationTree: AnimationTree
@export var animationPlayer: AnimationPlayer
@onready var movement_state_machine: AnimationNodeStateMachinePlayback

@export var skeleton: Skeleton3D
@export var physical_bones: PhysicalBoneSimulator3D

var is_ragdoll := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	movement_state_machine = animationTree.get("parameters/MovementStateMachine/playback")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func hit_animation() -> void:
	animationTree.set("parameters/HitOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func death_animation() -> void:
	#animationTree.set("parameters/DeathOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	enter_ragdoll()


func shoot_animation() -> void:
	animationTree.set("parameters/ShootOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func aiming_animation() -> void:
	movement_state_machine.travel("1H_Ranged_Aiming")


func idle_animation() -> void:
	movement_state_machine.travel("Idle")


func walk_animation() -> void:
	movement_state_machine.travel("Walking_C")


func enter_ragdoll():
	if is_ragdoll:
		return
	is_ragdoll = true

	await get_tree().create_timer(0.05, false).timeout
	# Stop character movement
	get_parent().set_physics_process(false)

	# Disable animation control
	animationTree.active = false

	# Enable physics on bones
	physical_bones.physical_bones_start_simulation()
	
	# Force wake-up
	#for bone in skeleton.get_children():
		#if bone is PhysicalBone3D:
			#bone.sleeping = false
			
	#physical_bones.active = true


func sit_chair_animation():
	movement_state_machine.travel("Sit_Chair_Down")

func sit_chair_stand_up():
	movement_state_machine.travel("Sit_Chair_StandUp")
