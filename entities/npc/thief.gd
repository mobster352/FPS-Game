extends CharacterBody3D

@export var game_state: GameState
@export var speed := 2.0

@onready var thief_skin: ThiefSkin
@onready var navigation_agent: ThiefNavigationAgent
@onready var walk_timer: Timer
@onready var item_slot: Node3D

var navigation_target: Node
var next_target: Node3D
var has_item:bool = false
var target_is_item:bool = false

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
	#navigation_agent.set_random_target()
	walk_timer = $Timers/WalkTimer
	item_slot = $ItemSlot
	current_state = ThiefState.Idle
	next_state = ThiefState.None
	game_state.set_thief_target.connect(_set_thief_target)

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
		if navigation_target and target_is_item:
			if navigation_target is Item:
				var item = navigation_target as Item
				item_slot.add_child(item.mesh.duplicate())
				item.call_deferred("queue_free")
			has_item = true
			game_state.clear_thief_target.emit(has_item)
			current_state = ThiefState.IdleHoldLargeObject
			navigation_target = null
			return
		elif navigation_target:
			navigation_target = null
			game_state.clear_thief_target.emit(false)
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

func _set_thief_target(target:Node3D, is_item:bool) -> void:
	if not next_target:
		next_target = target
		target_is_item = is_item

func hit() -> void:
	if has_item:
		var held_item = item_slot.get_child(0) as Node3D
		var item = GlobalVar.get_item_from_mesh(held_item.get_meta("name"))
		get_parent().add_child(item)
		item.global_transform = held_item.global_transform
		held_item.queue_free()
		has_item = false
		game_state.clear_thief_target.emit(false)
		next_state = ThiefState.Idle
