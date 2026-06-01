class_name BasicPlayer
extends CharacterBody3D


const SPEED = 5.5
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
@export var pointer_slot: Node3D
@export var mouse_sensitivity: float = 0.002
var invert := 1
var pause:bool = false
var is_sprinting:bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("pause"):
		pause = not pause
		if pause:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_just_pressed("sprint"):
		is_sprinting = not is_sprinting
	_process_movement()
	_process_camera()
	_process_jump()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_input += event.relative

func _process_movement() -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if is_sprinting:
			velocity.x = direction.x * SPRINT_SPEED
			velocity.z = direction.z * SPRINT_SPEED
		else:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
	else:
		if is_sprinting:
			velocity.x = move_toward(velocity.x, 0, SPRINT_SPEED)
			velocity.z = move_toward(velocity.z, 0, SPRINT_SPEED)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

var pitch := 0.0  # store vertical rotation manually
var mouse_input: Vector2 = Vector2.ZERO
func _process_camera() -> void:
	# Horizontal (yaw)
	rotate_y(-mouse_input.x * mouse_sensitivity)
	# Vertical (pitch)
	var vertical_change = -mouse_input.y * mouse_sensitivity
	pitch += vertical_change
	# Clamp BEFORE applying
	pitch = clamp(pitch, deg_to_rad(-70), deg_to_rad(70))
	# Apply rotation
	pointer_slot.rotation.x = pitch
	if OS.has_feature("web"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_input = Vector2.ZERO


func _process_jump() -> void:
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
