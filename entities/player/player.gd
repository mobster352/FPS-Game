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

@export var ui: UI

@export var item_slot: Node3D

@export var throw_strength: float = 5.0
@export var camera: Camera3D
#@export var player_skin: PlayerSkin
@export var pause_menu: PauseMenu
@export var game_over: Control
@export var death_timer: Timer
@export var hit_timer: Timer

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

var items_in_range: Array[Item]

var max_hp := 10
var hp := 10:
	set(value):
		ui.update_hp(hp, value)
		hp = value
		
var money := 0:
	set(value):
		money = value
		ui.update_money(money)
		
var spawn_position: Vector3
var is_alive := true
var freeze_camera := false
var restaurant: Restaurant

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	ammo_count = 10
	max_ammo = 10
	ammo_reserves = 20
	spawn_position = global_position
	GlobalSignal.init_restaurant.connect(_init_restaurant)
	
func _process(_delta: float) -> void:
	if is_alive:
		if Input.is_action_just_pressed("pause"):
			pause_menu.show()
			get_tree().paused = true
		_process_rayCast()
		if not freeze_camera:
			_process_movement()
			_process_shot()
			_process_draw_weapon()
			_process_crouch()
			_process_drop_item()

func _physics_process(delta: float) -> void:
	if is_alive:
		if not is_on_floor():
			velocity += get_gravity() * delta
		if not freeze_camera:
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
	if event is InputEventMouseMotion and is_alive and not freeze_camera:
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
		
		if OS.has_feature("web"):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process_shot() -> void:
	if weapon:
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
			var target = itemRaycast.get_collider() as Node3D
			if target:
				#print(target)
				if target.is_in_group("spawner"):
					for child in target.get_children():
						if items_in_range.has(target.get_parent().get_parent()) and child is ObjectSpawner:
							reticle.color = Color(0.0, 1.0, 0.0, 1.0)
							if Input.is_action_just_pressed("interact"):
								var obj = child.remove_object()
								if obj:
									if item_slot.get_child_count() > 0:
										drop_item()
									if obj.get_parent():
										obj.get_parent().remove_child(obj)
									obj.pickup(Vector3.ZERO, Vector3(deg_to_rad(10),deg_to_rad(130),deg_to_rad(0)))
									obj.queue_free()
						else:
							reticle.color = Color(255,255,255)
				elif target.get_parent() is Item:
					var obj = target.get_parent() as Item
					if items_in_range.has(obj) and not obj.disabled:
						reticle.color = Color(0.0, 1.0, 0.0, 1.0)
						if Input.is_action_just_pressed("interact"):
							if item_slot.get_child_count() > 0:
								drop_item()
							if obj.get_parent():
								obj.get_parent().remove_child(obj)
							if obj.has_meta("count"):
								obj.pickup(Vector3(0,-0.5,1.0), Vector3(-0.25,0,0))
							else:
								obj.pickup(Vector3.ZERO, Vector3(deg_to_rad(10),deg_to_rad(130),deg_to_rad(0)))
							obj.queue_free()
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
						if Input.is_action_just_pressed("interact"):
							if item_slot.get_child_count() > 0:
								drop_item()
							var obj = pizza.get_slice()
							if obj.get_parent():
								obj.get_parent().remove_child(obj)
							obj.pickup(Vector3.ZERO, Vector3(deg_to_rad(10),deg_to_rad(130),deg_to_rad(0)))
							obj.queue_free()
					else:
						reticle.color = Color(255,255,255)
				elif target is NPC_Dummy:
					var npc_dummy = target as NPC_Dummy
					if npc_dummy.in_range and not npc_dummy.has_order:
						reticle.color = Color(0.0, 1.0, 0.0, 1.0)
						if Input.is_action_just_pressed("interact"):
							npc_dummy.interact()
					else:
						reticle.color = Color(255,255,255)
				elif target is DriveThruCustomer:
					var customer = target as DriveThruCustomer
					if customer.in_range and not customer.has_order:
						reticle.color = Color(0.0, 1.0, 0.0, 1.0)
						if Input.is_action_just_pressed("interact"):
							customer.interact()
					else:
						reticle.color = Color(255,255,255)
				elif target.get_parent() is Billboard:
					var billboard = target.get_parent() as Billboard
					if billboard.in_range:
						reticle.color = Color(0.0, 1.0, 0.0, 1.0)
						if Input.is_action_just_pressed("interact"):
							billboard.show_billboard_ui()
							freeze_camera = true
					else:
						reticle.color = Color(255,255,255)
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
			ui.show_hp(false)
		else:
			#weapon = pew
			weapon = gun_pistol
			#pew.show()
			gun_pistol.show()
			ammo_label.show()
			if item_slot.get_child_count() > 0:
				drop_item()
			ui.show_hp(true)
			#player_skin.aiming_animation()

func _physics_logic() -> void:
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is RigidBody3D and not collider.get_parent().is_in_group("static"):
			collider.apply_central_impulse(-get_slide_collision(i).get_normal())

func _process_crouch() -> void:
	if Input.is_action_pressed("crouch"):
		scale = scale.slerp(Vector3(.5,.5,.5), 0.15)
	else:
		scale = scale.slerp(Vector3(1,1,1), 0.15)

func _process_drop_item() -> void:
	if item_slot.get_child_count() > 0 and Input.is_action_just_pressed("drop"):
		drop_item()

func drop_item() -> void:
	var child_mesh = item_slot.get_child(0) as MeshInstance3D
	item_slot.remove_child(child_mesh)
	
	if child_mesh.has_meta("name"):
		var item = GlobalVar.get_item_from_mesh(child_mesh.get_meta("name"))
		child_mesh.queue_free()
		if child_mesh.has_meta("count"):
			item.set_meta("count", child_mesh.get_meta("count"))
		get_parent().add_child(item)
		
		var forward = -camera.global_transform.basis.z.normalized()
		item.position = camera.global_position + forward
		
		item.set_monitoring(true)
		item.set_z_scale(false)
		for c in item.get_children():
			if c is RigidBody3D:
				c.freeze = false
				c.apply_impulse(forward * (throw_strength / c.mass), camera.global_position + forward)
				c.look_at(camera.global_position)
				if not item.has_meta("count"):
					c.rotate(Vector3.UP, deg_to_rad(130))
					c.rotate(Vector3.RIGHT, deg_to_rad(-20))
				var shape = c.get_child(0)
				if shape is CollisionShape3D:
					shape.disabled = false
		
		if item.has_meta("food_id"):
			var food_id = item.get_meta("food_id")
			if food_id:
				GlobalSignal.drop_food.emit(food_id)
				GlobalSignal.check_restaurant_food.emit(food_id)
		elif item.has_meta("plate_dirty"):
			item.pointer.show()
			GlobalSignal.toggle_pointer.emit("sink", false)


func append_item_in_range(item: Node3D) -> void:
	items_in_range.append(item)
	
	
func remove_item_in_range(item: Node3D) -> void:
	var index = items_in_range.find(item)
	items_in_range.remove_at(index)


func take_damage(value: int) -> void:
	if is_alive:
		hp -= value
		ui.take_damage()
		if not ui.is_hp_visible():
			ui.show_hp(true)
			hit_timer.start()
		if hp <= 0:
			is_alive = false
			game_over.show()
			death_timer.start()


func update_money(_money:int) -> void:
	money += _money

func _respawn() -> void:
	hp = max_hp
	global_position = spawn_position
	is_alive = true
	game_over.hide()


func _on_death_timer_timeout() -> void:
	_respawn()


func _on_hit_timer_timeout() -> void:
	if not weapon:
		ui.show_hp(false)

func _init_restaurant(_restaurant:Restaurant) -> void:
	restaurant = _restaurant
