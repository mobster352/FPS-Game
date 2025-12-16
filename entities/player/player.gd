extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var mouse_sensitivity: float = 0.002 # Adjust sensitivity as needed
@export var camera_pivot: Node3D # Drag your Node3D (Head) here in the Inspector

@export var shotRaycast: RayCast3D

var is_paused := false
var invert := -1

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		is_paused = not is_paused
		if is_paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_process_movement()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	_process_jump()
	#_process_movement()
	_process_shot()

func _process_jump() -> void:
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func _process_movement() -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_right", "move_left", "move_backward", "move_forward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
	
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not is_paused:
		# Horizontal rotation (Y-axis) applied to the main Player node
		# Rotate around the global up vector
		rotate_y(-event.relative.x * mouse_sensitivity)

		# Vertical rotation (X-axis) applied to the Camera Pivot node
		var vertical_change = -event.relative.y * mouse_sensitivity
		camera_pivot.rotate_x(invert * vertical_change)

		# Clamp vertical rotation to prevent the camera from flipping over
		var current_rotation_x = camera_pivot.rotation.x
		# Clamp between -90 and 90 degrees (converted to radians)
		camera_pivot.rotation.x = clamp(current_rotation_x, deg_to_rad(-90), deg_to_rad(90))

func _process_shot() -> void:
	if Input.is_action_just_pressed("shoot") and not is_paused:
		shoot()

func shoot() -> void:
	if shotRaycast.is_colliding():
		#var collider = shotRaycast.get_collider()
		var target = shotRaycast.get_collider() # A CollisionObject2D.
		#var shape_id = shotRaycast.get_collider_shape() # The shape index in the collider.
		#var owner_id = target.shape_find_owner(shape_id) # The owner ID in the collider.
		#var shape = target.shape_owner_get_owner(owner_id)
		#print(shape.name)
		if target.is_in_group("enemy_hitboxes"):
			print("Hit!")
		else:
			print("Missed!")
			#collider.take_damage(10) # Call a method on the enemy
	else:
		print("Missed!")
