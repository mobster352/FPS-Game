class_name ScreenCamera
extends Camera3D

const INITIAL_PITCH = -0.5

var player:Player
var initial_transform:Transform3D

func _ready() -> void:
	initial_transform = transform
	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	if player.current_input_device == GlobalVar.InputDevice.MOUSE_KEYBOARD:
		_process_camera()
	if current:
		_process_controller_turning(delta)


var pitch := INITIAL_PITCH  # store vertical rotation manually
var mouse_input: Vector2 = Vector2.ZERO
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and current:
		mouse_input += event.relative
		player.current_input_device = GlobalVar.InputDevice.MOUSE_KEYBOARD


func _process_controller_turning(delta:float) -> void:
	var look := Input.get_vector("look_left", "look_right", "look_up", "look_down")

	if look.length() > player.controller_deadzone:
		player.is_looking = true

		rotate_y(-look.x * player.controller_sensitivity * delta)

		pitch -= look.y * player.controller_sensitivity * delta
		pitch = clamp(
			pitch,
			deg_to_rad(player.min_pitch_deg),
			deg_to_rad(player.max_pitch_deg)
		)
		rotation.x = pitch
		
		player.current_input_device = GlobalVar.InputDevice.CONTROLLER
	else:
		player.is_looking = false
		look = Vector2.ZERO


func _process_camera() -> void:
	# Horizontal (yaw)
	rotate_y(-mouse_input.x * player.mouse_sensitivity)
	# Vertical (pitch)
	var vertical_change = -mouse_input.y * player.mouse_sensitivity
	pitch += vertical_change
	# Clamp BEFORE applying
	pitch = clamp(pitch, deg_to_rad(-70), deg_to_rad(70))
	# Apply rotation
	rotation.x = pitch
	if OS.has_feature("web"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_input = Vector2.ZERO


func reset_transform() -> void:
	transform = initial_transform
	pitch = INITIAL_PITCH
