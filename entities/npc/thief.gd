extends CharacterBody3D
class_name Thief

@export var game_state: GameState
@export var speed := 2.0

@onready var thief_skin: ThiefSkin
@onready var navigation_agent: ThiefNavigationAgent
@onready var walk_timer: Timer
@onready var steal_timer: Timer
@onready var item_slot: Node3D

var navigation_target: Node
var next_target: Node3D
var has_item:bool = false

enum ThiefState {
	None,
	Idle,
	Walk,
	IdleHoldLargeObject,
	WalkHoldLargeObject
}

var current_state: ThiefState
var next_state: ThiefState

func _ready() -> void:
	thief_skin = $Rig
	navigation_agent = $NavigationAgent3D
	walk_timer = $Timers/WalkTimer
	steal_timer = $Timers/StealTimer
	item_slot = $ItemSlot
	current_state = ThiefState.Idle
	next_state = ThiefState.None

func _physics_process(delta: float) -> void:
	if next_state:
		current_state = next_state
		next_state = ThiefState.None
	match current_state:
		ThiefState.Idle:
			idle()
		ThiefState.Walk:
			walk(delta)
		ThiefState.IdleHoldLargeObject:
			idle_hold_large_object()
		ThiefState.WalkHoldLargeObject:
			walk_hold_large_object(delta)
		_:
			pass

func idle() -> void:
	thief_skin.idle_animation()
	if not walk_timer.time_left:
		walk_timer.start()

func walk(delta:float) -> void:
	if navigation_agent.is_navigation_finished():
		if navigation_target:
			if navigation_target is Item and not navigation_target.is_queued_for_deletion():
				var item = navigation_target as Item
				if item.has_meta("count"):
					if item.has_node("body/Interactable"):
						var node = item.get_node("body/Interactable")
						if node is ObjectSpawner:
							item.mesh.set_meta("item_type", node.item_type)
							item.mesh.set_meta("count", item.get_meta("count"))
				item_slot.add_child(item.mesh.duplicate())
				item.call_deferred("queue_free")
				has_item = true
				current_state = ThiefState.IdleHoldLargeObject
			elif navigation_target is GenericSpawner and not navigation_target.is_queued_for_deletion():
				var object_spawner = navigation_target as GenericSpawner
				var mesh = load(object_spawner.mesh_path).instantiate() as Node3D
				mesh.set_meta("name", object_spawner.mesh_name)
				item_slot.add_child(mesh)
				object_spawner.thief_remove_object()
				has_item = true
				current_state = ThiefState.IdleHoldLargeObject
			elif navigation_target is PizzaBoxStack and not navigation_target.is_queued_for_deletion():
				var pizza_box_stack = navigation_target as PizzaBoxStack
				var mesh = pizza_box_stack.pizzabox.instantiate() as Node3D
				mesh.set_meta("name", "pizza_box_open_mesh")
				item_slot.add_child(mesh)
				pizza_box_stack.thief_remove_box_from_stack()
				has_item = true
				current_state = ThiefState.IdleHoldLargeObject
			else:
				has_item = false
				current_state = ThiefState.Idle
			navigation_target = null
			return
		elif navigation_target:
			navigation_target = null
		current_state = ThiefState.Idle
	else:
		thief_skin.walk_animation()
		var destination = navigation_agent.get_next_path_position()
		var local_destination = destination - global_position
		var direction = local_destination.normalized()
		var new_velocity = direction * speed
		velocity = new_velocity
		move_and_slide()
		_look_at_target(destination, delta)
	
func idle_hold_large_object() -> void:
	thief_skin.idle_hold_large_object_animation()
	if not walk_timer.time_left:
		walk_timer.start()

func walk_hold_large_object(delta:float) -> void:
	if navigation_agent.is_navigation_finished():
		current_state = ThiefState.IdleHoldLargeObject
	else:
		thief_skin.walk_hold_large_object_animation()
		var destination = navigation_agent.get_next_path_position()
		var local_destination = destination - global_position
		var direction = local_destination.normalized()
		var new_velocity = direction * speed
		velocity = new_velocity
		move_and_slide()
		_look_at_target(destination, delta)

func _look_at_target(pos: Vector3, delta: float) -> void:
	var direction: Vector3 = -global_position.direction_to(pos)
	if direction != Vector3.ZERO:
		var _target: Basis = Basis.looking_at(direction, Vector3.UP)
		basis = basis.slerp(_target, 5 * delta).orthonormalized()


func _on_walk_timer_timeout() -> void:
	if has_item:
		current_state = ThiefState.WalkHoldLargeObject
		navigation_agent.set_random_target()
	else:
		current_state = ThiefState.Walk
		if next_target:
			navigation_target = next_target
			navigation_agent.set_target(navigation_target)
			next_target = null
		else:
			navigation_agent.set_random_target()
			if not steal_timer.time_left:
				steal_timer.wait_time = get_random_time()
				steal_timer.start()


func hit() -> void:
	if has_item:
		var held_item = item_slot.get_child(0) as Node3D
		if held_item:
			var item = GlobalVar.get_item_from_mesh(held_item.get_meta("name"))
			if item:
				if item.has_node("body/Interactable"):
					var node = item.get_node("body/Interactable")
					if node is ObjectSpawner:
						node.item_type = held_item.get_meta("item_type")
						item.set_meta("count", held_item.get_meta("count"))
				get_parent().add_child(item)
				item.global_transform = held_item.global_transform
				item.scale = Vector3(1,1,1)
				held_item.queue_free()
			thief_skin.hit_animation()
		has_item = false
		current_state = ThiefState.Idle

func get_random_time() -> float:
	return randi_range(20, 40)


func _on_steal_timer_timeout() -> void:
	if not is_instance_valid(navigation_target):
		navigation_target = null
	if not next_target:
		var target = game_state.get_target(navigation_target, has_item)
		if target:
			next_target = target
