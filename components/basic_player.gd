class_name BasicPlayer
extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var mouse_sensitivity: float = 0.002
var invert := 1
var pause:bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


var pitch := 0.0  # store vertical rotation manually
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Horizontal (yaw)
		rotate_y(-event.relative.x * mouse_sensitivity)

		# Vertical (pitch)
		var vertical_change = -event.relative.y * mouse_sensitivity * invert
		pitch += vertical_change

		# Clamp BEFORE applying
		pitch = clamp(pitch, deg_to_rad(-90), deg_to_rad(90))

		# Apply rotation
		%Camera3D.rotation.x = pitch

		if OS.has_feature("web"):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	if event.is_action_pressed("pause"):
		pause = not pause
		if pause:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
