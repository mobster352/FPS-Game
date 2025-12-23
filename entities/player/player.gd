extends CharacterBody3D
class_name Player

signal weapon_fired

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var mouse_sensitivity: float = 0.002
@export var camera_pivot: Node3D

@export var shotRaycast: RayCast3D
@export var reticle: ColorRect

@export var weapon: Node3D
@export var shotTimer: Timer

@export var ui: Control
@export var pew:Pew

var is_paused := false
var invert := -1

var max_ammo: int
var ammo_count: int:
	set(value):
		ammo_count = value
		ui.update_ammo(value, ammo_reserves)

var ammo_reserves: int:
	set(value):
		ammo_reserves = value
		ui.update_ammo(ammo_count, value)

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	ammo_count = 10
	max_ammo = 10
	ammo_reserves = 20
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		is_paused = not is_paused
		if is_paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_process_rayCast()
	_process_movement()
	_process_shot()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	_process_jump()

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
	if not is_paused:
		if Input.is_action_just_pressed("shoot") and ammo_count - 1 >= 0:
			shoot()
			ammo_count -= 1
			weapon_fired.emit()
			pew.add_muzzle_flash()
		if Input.is_action_just_pressed("reload") and ammo_reserves > 0 and ammo_count < max_ammo:
			var ammo_needed = max_ammo - ammo_count
			if ammo_reserves >= ammo_needed:
				ammo_count += ammo_needed
				ammo_reserves -= ammo_needed
			else:
				ammo_count += ammo_reserves
				ammo_reserves = 0

func shoot() -> void:
	if shotRaycast.is_colliding():
		var target = shotRaycast.get_collider() as Node3D # A CollisionObject2D.
		#var shape_id = shotRaycast.get_collider_shape() # The shape index in the collider.
		#var owner_id = target.shape_find_owner(shape_id) # The owner ID in the collider.
		#var shape = target.shape_owner_get_owner(owner_id)
		#print(shape.name)
		
		if target.is_in_group("enemy_hitboxes"):
			var parent = target.get_parent()
			if parent:
				if parent.has_method("take_damage"):
					parent.call("take_damage", 1)
	else:
		print("Missed!")
	if weapon and weapon.has_method("shoot_animation"):
		weapon.call("shoot_animation")
		#shotTimer.start()

func _process_rayCast() -> void:
	if shotRaycast.is_colliding():
		var target = shotRaycast.get_collider()
		if target:
			if target.is_in_group("enemy_hitboxes"):
				reticle.color = Color(255,0,0)
	else:
		reticle.color = Color(1,1,1)
