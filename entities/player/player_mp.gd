# player.gd
extends CharacterBody3D
class_name PlayerMP

const SPEED = 3.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Set by the authority, synchronized on spawn.
@export var player := 1 :
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)

# Player synchronized input.
@onready var input = $PlayerInput

@export var server_synchronizer: MultiplayerSynchronizer
@export var player_input_synchronizer: MultiplayerSynchronizer

var mouse_sensitivity: float = 0.002
var invert := -1
@export var camera_pivot: Node3D
@export var camera: Camera3D
@export var skin: PlayerSkin
@export var name_label: Label3D

enum State {
	None,
	Idle,
	Walk
}
var state:State

func _ready():
	if player == multiplayer.get_unique_id():
		camera.current = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		skin.head.set_layer_mask_value(1, false)
		skin.head.set_layer_mask_value(2, true)
		skin.helmut.set_layer_mask_value(1, false)
		skin.helmut.set_layer_mask_value(2, true)
	state = State.Idle
	set_process_input(player == multiplayer.get_unique_id())

func _physics_process(delta:float):
	match state:
		State.Idle:
			idle_physics(delta)
		State.Walk:
			walk_physics(delta)

func idle_physics(delta:float) -> void:
	skin.idle_animation()
	process_jump(delta)
	var direction = (transform.basis * Vector3(input.direction.x, 0, input.direction.y)).normalized()
	if direction:
		state = State.Walk
	move_and_slide()

func walk_physics(delta:float) -> void:
	skin.walk_animation()
	process_movement(delta)
	process_jump(delta)
	move_and_slide()

func _process(_delta: float) -> void:
	rotate_player()
	match state:
		State.Idle:
			idle()
		State.Walk:
			walk()
			
func idle() -> void:
	pass
	
func walk() -> void:
	pass
	
func process_movement(_delta: float) -> void:
	if input.is_paused:
		return

	var direction = (transform.basis * Vector3(input.direction.x, 0, input.direction.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		state = State.Idle

func process_jump(delta:float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if input.jumping and is_on_floor():
		velocity.y = JUMP_VELOCITY

	input.jumping = false

func rotate_player() -> void:
	rotate_y(-input.mouse_input.x * mouse_sensitivity)

	var vertical_change = -input.mouse_input.y * mouse_sensitivity
	camera_pivot.rotate_x(invert * vertical_change)

	var current_rotation_x = camera_pivot.rotation.x
	camera_pivot.rotation.x = clamp(current_rotation_x, deg_to_rad(-60), deg_to_rad(45))
	skin.head_pivot.rotation.x = clamp(-camera_pivot.rotation.x, deg_to_rad(-30), deg_to_rad(30))
	input.mouse_input = Vector2.ZERO
	
