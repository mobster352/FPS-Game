extends CharacterBody3D
class_name Player

signal weapon_fired

const SPEED = 5.0
@export var JUMP_VELOCITY := 6.0

@export var mouse_sensitivity: float = 0.002
@export var pointer_slot: Node3D

@export var shotRaycast: RayCast3D
@export var itemRaycast: RayCast3D

@export var reticle: ColorRect

#@export var pew: Pew
@export var gun_pistol: GunPistol
var weapon: Weapon

@export var ammo_label: RichTextLabel
@export var shotTimer: Timer

@export var ui: Control

@export var item_slot: Node3D

@export var throw_strength: int = 4
@export var camera: Camera3D
#@export var player_skin: PlayerSkin

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

var items_in_range: Array[Node3D]

var max_hp := 10
var hp := 10:
	set(value):
		ui.update_hp(hp, value)
		hp = value

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
	_process_draw_weapon()
	_process_crouch()
	_process_drop_item()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	_process_jump()
	_physics_logic()

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
		pointer_slot.rotate_x(invert * vertical_change)

		# Clamp vertical rotation to prevent the camera from flipping over
		var current_rotation_x = pointer_slot.rotation.x
		# Clamp between -90 and 90 degrees (converted to radians)
		pointer_slot.rotation.x = clamp(current_rotation_x, deg_to_rad(-90), deg_to_rad(90))
		
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process_shot() -> void:
	if not is_paused and weapon:
		if Input.is_action_just_pressed("shoot") and ammo_count - 1 >= 0:
			shoot()
			ammo_count -= 1
			weapon_fired.emit()
			weapon.add_muzzle_flash()
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
		var shape_id = shotRaycast.get_collider_shape() # The shape index in the collider.
		var owner_id = target.shape_find_owner(shape_id) # The owner ID in the collider.
		var shape = target.shape_owner_get_owner(owner_id)
		#print(shape.name)
		if target.is_in_group("enemies"):
			if target.has_method("take_damage"):
				target.call("take_damage", 1, shape)
		elif target.get_parent().is_in_group("enemies"):
			var parent = target.get_parent()
			if parent:
				if parent.has_method("take_damage"):
					parent.call("take_damage", 1, shape)
	weapon.shoot_animation()

func _process_rayCast() -> void:
	if weapon:
		if shotRaycast.is_colliding():
			var target = shotRaycast.get_collider()
			if target:
				if target.is_in_group("enemies"):
					reticle.color = Color(255,0,0)
				elif target.get_parent().is_in_group("enemies"):
					reticle.color = Color(255,0,0)
				else:
					reticle.color = Color(255,255,255)
		else:
			reticle.color = Color(255,255,255)
	else:
		if itemRaycast.is_colliding():
			var target = itemRaycast.get_collider()
			if target:
				if target.get_parent() is Item:
					var obj = target.get_parent() as Item
					if items_in_range.has(obj):
						reticle.color = Color(0.0, 1.0, 0.0, 1.0)
						if Input.is_action_just_pressed("shoot"):
							if item_slot.get_child_count() > 0:
								drop_item()
							if obj.get_parent():
								obj.get_parent().remove_child(obj)
							item_slot.add_child(obj)
							obj.pickup(Vector3(deg_to_rad(110),deg_to_rad(150),deg_to_rad(20)))
					else:
						reticle.color = Color(255,255,255)
				elif target.get_parent() is Door:
					var door = target.get_parent() as Door
					if door.in_range:
						reticle.color = Color(0.0, 1.0, 0.0, 1.0)
					else:
						reticle.color = Color(255,255,255)
					if Input.is_action_just_pressed("interact"):
						door.door_interact()
				elif target.get_parent() is Pizza:
					var pizza = target.get_parent() as Pizza
					if pizza.in_range:
						reticle.color = Color(0.0, 1.0, 0.0, 1.0)
					else:
						reticle.color = Color(255,255,255)
					if Input.is_action_just_pressed("interact"):
						if item_slot.get_child_count() > 0:
							drop_item()
						var obj = pizza.get_slice()
						item_slot.add_child(obj)
						obj.pickup(Vector3(deg_to_rad(110),deg_to_rad(150),deg_to_rad(20)))
				else:
					reticle.color = Color(255,255,255)
			else:
				reticle.color = Color(255,255,255)
		else:
			reticle.color = Color(255,255,255)


func _process_draw_weapon() -> void:
	if Input.is_action_just_pressed("draw_weapon_1"):
		if weapon:
			weapon = null
			#pew.hide()
			gun_pistol.hide()
			ammo_label.hide()
			reticle.color = Color(255,255,255)
		else:
			#weapon = pew
			weapon = gun_pistol
			#pew.show()
			gun_pistol.show()
			ammo_label.show()
			if item_slot.get_child_count() > 0:
				drop_item()
			#player_skin.aiming_animation()

func _physics_logic() -> void:
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is RigidBody3D:
			collider.apply_central_impulse(-get_slide_collision(i).get_normal())

func _process_crouch() -> void:
	if Input.is_action_pressed("crouch"):
		scale = Vector3(.5,.5,.5)
	else:
		scale = Vector3(1,1,1)

func _process_drop_item() -> void:
	if item_slot.get_child_count() > 0 and Input.is_action_just_pressed("drop"):
		drop_item()

func drop_item() -> void:
	var child = item_slot.get_child(0) as Item
	item_slot.remove_child(child)
	get_parent().add_child(child)
	
	var forward = -camera.global_transform.basis.z.normalized()
	child.position = camera.global_position + forward
	
	child.set_monitoring(true)
	child.set_z_scale(false)
	for c in child.get_children():
		if c is RigidBody3D:
			c.freeze = false
			c.apply_impulse(forward * (throw_strength / c.mass), camera.global_position + forward)
			var shape = c.get_child(0)
			if shape is CollisionShape3D:
				shape.disabled = false


func append_item_in_range(item: Node3D) -> void:
	items_in_range.append(item)
	
	
func remove_item_in_range(item: Node3D) -> void:
	var index = items_in_range.find(item)
	items_in_range.remove_at(index)


func take_damage(value: int) -> void:
	hp -= value
	ui.take_damage()
	#print("Player took ", value, " damage.")
	#print("HP: ", hp)
	if hp <= 0:
		get_tree().reload_current_scene()
