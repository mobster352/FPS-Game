extends Camera3D

@export var player: Player

@export var move_speed := 12.0
@export var sprint_multiplier := 3.0
@export var mouse_sensitivity := 0.002
@export var vertical_speed := 8.0

var flyover_active := false
var yaw := 0.0
var pitch := 0.0


func _ready() -> void:
	yaw = rotation.y
	pitch = rotation.x


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("switch_pov"):
		flyover_active = !flyover_active
		current = flyover_active

		GlobalSignal.freeze_player_camera.emit(flyover_active)
		player.ui.visible = not flyover_active

		if flyover_active:
			yaw = rotation.y
			pitch = rotation.x


func _input(event: InputEvent) -> void:
	if not flyover_active:
		return

	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, deg_to_rad(-89), deg_to_rad(89))

		rotation = Vector3(pitch, yaw, 0.0)


func _physics_process(delta: float) -> void:
	if not flyover_active:
		return

	var input_dir := Input.get_vector(
		"move_left",
		"move_right",
		"move_backward",
		"move_forward"
	)

	var direction := Vector3.ZERO

	direction += -global_transform.basis.z * input_dir.y
	direction += global_transform.basis.x * input_dir.x

	if Input.is_action_pressed("fly_up"):
		direction += Vector3.UP

	if Input.is_action_pressed("fly_down"):
		direction += Vector3.DOWN

	direction = direction.normalized()

	var speed := move_speed
	if Input.is_action_pressed("sprint"):
		speed *= sprint_multiplier

	global_position += direction * speed * delta
