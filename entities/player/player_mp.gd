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

@export var item_slot: Node3D
@export var inputs_ui: InputsUI
@export var throw_strength: float = 5.0

var interact:bool
var drop_input:bool

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
	set_process_input(is_current_player())
	GlobalSignal.init_player_mp.emit(self)

func _physics_process(delta:float):
	match state:
		State.Idle:
			idle_physics(delta)
		State.Walk:
			walk_physics(delta)
	_process_drop_item()


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
	interact = Input.is_action_just_pressed("interact")
	drop_input = Input.is_action_just_pressed("drop")


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
	camera_pivot.rotation.x = clamp(current_rotation_x, deg_to_rad(-45), deg_to_rad(60))
	skin.head_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-30), deg_to_rad(30))
	input.mouse_input = Vector2.ZERO


func has_held_object() -> bool:
	return item_slot.get_child_count() > 0


func drop_item() -> void:
	if has_held_object():
		#cancel_placement(false)
		var child_mesh = item_slot.get_child(0)
		if child_mesh:
			if is_host():
				if child_mesh.has_meta("name"):
					var item = GlobalVar.get_item_from_mesh(child_mesh.get_meta("name"))
					var forward = -camera.global_transform.basis.z.normalized()
					if child_mesh.has_meta("count"):
						item.set_meta("count", child_mesh.get_meta("count"))
						var object_spawner = item.get_node("body/Interactable") as ObjectSpawner
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
					if item.mesh.has_meta("toppings"):
						if item.has_node("body/Cookable"):
							var cookable = item.get_node("body/Cookable") as Cookable
							cookable.toppings = item.mesh.get_meta("toppings")
						
					item.mesh.rotation = Vector3.ZERO
					get_node("../../Objects").add_child(item, true)
					
					item.meshInstanceArray.append(item.mesh)
					item.set_monitoring(true)
					item.set_z_scale(false)
					for c in item.get_children():
						if c is RigidBody3D:
							c.freeze = false
							c.apply_central_impulse(forward * (throw_strength / c.mass))
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
					
					child_mesh.queue_free()
			else:
				if child_mesh.has_meta("name"):
					var forward = -camera.global_transform.basis.z.normalized()
					var item_position = camera.global_position + forward
					GlobalSignal.player_drop_item.emit(child_mesh.get_meta("name"), item_position, camera.global_rotation, player)


func _process_drop_item() -> void:
	if player != multiplayer.get_unique_id():
		return
	if has_held_object() and not item_slot.get_child(0).has_meta("pizzaboxes"):
		if drop_input:
			drop_item()
			

func is_current_player() -> bool:
	return player == multiplayer.get_unique_id()


func is_host() -> bool:
	return multiplayer.is_server()
