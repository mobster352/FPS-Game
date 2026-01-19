extends CharacterBody3D
class_name Player

signal weapon_fired

const RETICLE_WHITE := Color(255,255,255)
const RETICLE_RED := Color(255,0,0)
const RETICLE_GREEN := Color(0.0, 1.0, 0.0, 1.0)

const SPEED = 5.0
@export var JUMP_VELOCITY := 6.0

@export var mouse_sensitivity: float = 0.002
@export var pointer_slot: Node3D

@export var shotRaycast: RayCast3D
@export var itemRaycast: RayCast3D

@export var reticle: ColorRect

@export var gun_pistol: GunPistol
@export var bat: Bat
@export var has_pistol: bool
@export var has_bat: bool
var weapon: Weapon

@export var ammo_label: RichTextLabel
@export var shotTimer: Timer

@export var ui: UI

@export var item_slot: Node3D

@export var throw_strength: float = 5.0
@export var camera: Camera3D
@export var pause_menu: PauseMenu
@export var game_over: Control
@export var death_timer: Timer
@export var hit_timer: Timer

var invert := -1

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

@export var max_distance := 5.0

var place_scene: PackedScene
var preview_instance: Node3D
var can_place := false
var place_scene_item_type: GlobalVar.StoreItem

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
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
		if Input.is_action_just_pressed("shoot") and weapon.ammo_count - 1 >= 0 and weapon.has_ammo:
			shoot()
			weapon.ammo_count -= 1
			weapon_fired.emit()
			weapon.add_muzzle_flash()
		if Input.is_action_just_pressed("shoot") and not weapon.has_ammo:
			weapon.shoot_animation()
		if Input.is_action_just_pressed("reload") and weapon.ammo_reserves > 0 and weapon.ammo_count < weapon.max_ammo and weapon.has_ammo:
			var ammo_needed = weapon.max_ammo - weapon.ammo_count
			if weapon.ammo_reserves >= ammo_needed:
				weapon.ammo_count += ammo_needed
				weapon.ammo_reserves -= ammo_needed
			else:
				weapon.ammo_count += weapon.ammo_reserves
				weapon.ammo_reserves = 0

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
	reticle.color = RETICLE_WHITE
	
	var ray: RayCast3D
	if weapon:
		ray = shotRaycast
	else:
		ray = itemRaycast
		
	if not ray.is_colliding():
		return
		
	var target := ray.get_collider()
	if not target:
		return
		
	if weapon:
		_handle_weapon_raycast(target)
	else:
		_handle_item_raycast(target)


func _handle_weapon_raycast(target: Node3D) -> void:
	if target.is_in_group("enemies") or target.get_parent().is_in_group("enemies"):
		reticle.color = RETICLE_RED


func _handle_item_raycast(target: Node3D) -> void:
	var interact := Input.is_action_just_pressed("interact")
	
	var interactable := target as Interactable
	if not interactable:
		interactable = target.get_parent() as Interactable
	if not interactable and target.has_node("Interactable"):
		interactable = target.get_node("Interactable") as Interactable

	if interactable:
		if interactable.can_interact():
			reticle.color = interactable.reticle_color()
			if interact:
				interactable.interact(self)

	var cook_input := Input.is_action_just_pressed("cook")
	
	var cookable := target as Cookable
	if not cookable and target.has_node("Cookable"):
		cookable = target.get_node("Cookable")
	
	if cookable:
		if cookable.can_cook():
			reticle.color = cookable.reticle_color()
			if cook_input:
				cookable.cook(self)


func _process_draw_weapon() -> void:
	if Input.is_action_just_pressed("draw_weapon_1") and has_bat:
		if weapon == bat:
			bat.unequip()
			weapon = null
			reticle.show()
		elif weapon == null:
			bat.equip()
			weapon = bat
			if item_slot.get_child_count() > 0:
				drop_item()
			reticle.hide()
		else:
			gun_pistol.unequip()
			bat.equip()
			weapon = bat
			reticle.hide()
		reticle.color = RETICLE_WHITE
	if Input.is_action_just_pressed("draw_weapon_2") and has_pistol:
		if weapon == gun_pistol:
			gun_pistol.unequip()
			weapon = null
			reticle.show()
		elif weapon == null:
			gun_pistol.equip()
			weapon = gun_pistol
			if item_slot.get_child_count() > 0:
				drop_item()
			reticle.show()
		else:
			bat.unequip()
			gun_pistol.equip()
			weapon = gun_pistol
			reticle.show()
		reticle.color = RETICLE_WHITE

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
	var drop_input = Input.is_action_just_pressed("drop")
	if item_slot.get_child_count() > 0:
		var item = item_slot.get_child(0)
		if item.has_meta("place"):
			#if item.has_meta("name"):
				#if item.get_meta("name") == "crate_mesh":
			if preview_instance:
				update_preview()
			if drop_input:
				confirm_placement()
		else:
			if drop_input:
				drop_item()

func start_placement(preview_scene: PackedScene, place_scene_path: StringName, item_type: GlobalVar.StoreItem):
	if preview_instance:
		return

	preview_instance = preview_scene.instantiate()
	get_tree().current_scene.add_child(preview_instance)
	
	place_scene = load(place_scene_path)
	place_scene_item_type = item_type

	_make_preview_material(preview_instance)


func update_preview():
	var space_state = get_world_3d().direct_space_state

	var from = camera.global_position
	var forward = -camera.global_transform.basis.z
	var to = from + forward * max_distance

	# Forward ray
	var forward_query = PhysicsRayQueryParameters3D.create(from, to)
	var forward_hit = space_state.intersect_ray(forward_query)

	var target_point = to
	if forward_hit:
		target_point = forward_hit.position

	# Downward ray
	var down_query = PhysicsRayQueryParameters3D.create(
		target_point + Vector3.UP * 2.0,
		target_point + Vector3.DOWN * 10.0
	)

	var down_hit = space_state.intersect_ray(down_query)

	if down_hit:
		can_place = true
		preview_instance.global_position = down_hit.position
		preview_instance.global_rotation.y = camera.global_rotation.y
	else:
		can_place = false

	_update_preview_color(can_place)
	
func confirm_placement():
	if not can_place or not preview_instance:
		return

	var instance = place_scene.instantiate() as Item
	if instance.has_node("body/StaticBody3D/Interactable"):
		var interactable = instance.get_node("body/StaticBody3D/Interactable")
		if interactable is ObjectSpawner:
			interactable.item_type = place_scene_item_type
			
	var child_mesh = item_slot.get_child(0) as MeshInstance3D
	if child_mesh.has_meta("food_id"):
			instance.set_meta("food_id", child_mesh.get_meta("food_id"))
		
	if instance.has_meta("food_id"):
		var food_id = instance.get_meta("food_id")
		if food_id:
			GlobalSignal.drop_food.emit(food_id)
			GlobalSignal.check_restaurant_food.emit(food_id)
	elif instance.has_meta("plate_dirty"):
		instance.pointer.show()
		GlobalSignal.toggle_pointer.emit("sink", false)
			
	instance.global_transform = preview_instance.global_transform
	get_tree().current_scene.add_child(instance)

	cancel_placement()
	
func cancel_placement():
	if preview_instance:
		preview_instance.queue_free()
		preview_instance = null
		place_scene_item_type = GlobalVar.StoreItem.None
		var child_mesh = item_slot.get_child(0) as MeshInstance3D
		item_slot.remove_child(child_mesh)
		child_mesh.queue_free()
	
func _make_preview_material(root: Node):
	for child in root.get_children(true):
		if child is MeshInstance3D:
			var mat = StandardMaterial3D.new()
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.albedo_color = Color(0, 1, 0, 0.35)
			mat.no_depth_test = true
			child.material_override = mat
			
func _update_preview_color(valid: bool):
	var color
	if valid:
		color = Color(0, 1, 0, 0.35)
	else:
		color = Color(1, 0, 0, 0.35)

	for child in preview_instance.find_children("*", "MeshInstance3D", true):
		if child is MeshInstance3D:
			child.material_override.albedo_color = color

func drop_item() -> void:
	var child_mesh = item_slot.get_child(0) as MeshInstance3D
	if child_mesh.has_meta("name"):
		var item = GlobalVar.get_item_from_mesh(child_mesh.get_meta("name"))
		var forward = -camera.global_transform.basis.z.normalized()
		if child_mesh.has_meta("count"):
			item.set_meta("count", child_mesh.get_meta("count"))
			var object_spawner = item.get_node("body/StaticBody3D/Interactable") as ObjectSpawner
			object_spawner.item_type = child_mesh.get_meta("item_type")
			item.position = camera.global_position + forward + Vector3(0,-0.5,0.0)
		else:
			item.position = camera.global_position + forward
		item.mesh = child_mesh.duplicate()
		if item.has_node("body/mesh"):
			var mesh_node = item.get_node("body/mesh")
			mesh_node.remove_child(mesh_node.get_child(0))
			mesh_node.add_child(item.mesh)
		if item.mesh.get_child_count() > 0:
			item.mesh_has_children = true
			item.set_z_scale_children(false, item.mesh)
		item.mesh.rotation = Vector3.ZERO
		get_parent().add_child(item)
		
		item.meshInstanceArray.append(item.mesh)
		item.set_monitoring(true)
		item.set_z_scale(false)
		for c in item.get_children():
			if c is RigidBody3D:
				c.freeze = false
				c.apply_impulse(forward * (throw_strength / c.mass), camera.global_position + forward)
				if item is PizzaBox:
					c.look_at(camera.global_position)
					c.rotate(Vector3.UP, deg_to_rad(180))
				elif not item.has_meta("count"):
					c.look_at(camera.global_position)
					c.rotate(Vector3.UP, deg_to_rad(130))
					c.rotate(Vector3.RIGHT, deg_to_rad(-20))
				else:
					c.look_at(camera.global_position - Vector3(0,1,0))
		
		if child_mesh.has_meta("food_id"):
			item.set_meta("food_id", child_mesh.get_meta("food_id"))
		
		if item.has_meta("food_id"):
			var food_id = item.get_meta("food_id")
			if food_id:
				GlobalSignal.drop_food.emit(food_id)
				GlobalSignal.check_restaurant_food.emit(food_id)
		elif item.has_meta("plate_dirty"):
			item.pointer.show()
			GlobalSignal.toggle_pointer.emit("sink", false)

	item_slot.remove_child(child_mesh)
	child_mesh.queue_free()

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
