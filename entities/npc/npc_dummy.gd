extends CharacterBody3D
class_name NPC_Dummy

@export var dummy_scene: PackedScene
var dummy: Dummy
@export var dialogue_box: DialogueBox
@export var speed := 1.5
@export var area_col: CollisionShape3D
@export var navigation_agent: NavigationAgent3D
@export var start_target: Marker3D
@export var pointer: Node3D
@export var endPathMarker: Marker3D

@export var level_ui: Level_UI
@export var walk_in_store_odds := 16

@onready var initial_parent = get_parent()

var target: Marker3D:
	set(value):
		target = value
var table: Table
var in_range:bool = false
var has_order:bool = false
var sitting:bool = false
var navigation_ready:bool = false
var random_food:int

var is_waiting_on_table:bool = false

var player:Player
var order_total:int

var is_enabled:bool = false

enum NPCState {
	None,
	Idle,
	Walking,
	Sitting
}
var current_state:NPCState
var next_state:NPCState
var previous_state:NPCState

enum NpcChoices {
	Random,
	Pizza_Shop,
	Park
}
var npc_choices:Array[NpcChoices] = [
	NpcChoices.Random,
	NpcChoices.Pizza_Shop,
	NpcChoices.Park
]

var is_store_open:bool = false
var has_quest:bool = false
var is_quest_complete:bool = false

func enable_npc(enable:bool) -> void:
	is_enabled = enable
	if enable:
		if not GlobalSignal.assign_customer_to_table.is_connected(_assign_customer_to_table):
			GlobalSignal.assign_customer_to_table.connect(_assign_customer_to_table)
		if not GlobalSignal.remove_customer.is_connected(_remove_customer):
			GlobalSignal.remove_customer.connect(_remove_customer)
		if not GlobalSignal.process_payment.is_connected(_process_payment):
			GlobalSignal.process_payment.connect(_process_payment)
		if not GlobalSignal.check_for_open_table.is_connected(_check_for_open_table):
			GlobalSignal.check_for_open_table.connect(_check_for_open_table)
		if not NavigationServer3D.map_changed.is_connected(_navigation_server_map_changed):
			NavigationServer3D.map_changed.connect(_navigation_server_map_changed)
		next_state = NPCState.Idle
		target = null
		show()
		set_physics_process(true)
	else:
		if GlobalSignal.assign_customer_to_table.is_connected(_assign_customer_to_table):
			GlobalSignal.assign_customer_to_table.disconnect(_assign_customer_to_table)
		if GlobalSignal.remove_customer.is_connected(_remove_customer):
			GlobalSignal.remove_customer.disconnect(_remove_customer)
		if GlobalSignal.process_payment.is_connected(_process_payment):
			GlobalSignal.process_payment.disconnect(_process_payment)
		if GlobalSignal.check_for_open_table.is_connected(_check_for_open_table):
			GlobalSignal.check_for_open_table.disconnect(_check_for_open_table)
		if NavigationServer3D.map_changed.is_connected(_navigation_server_map_changed):
			NavigationServer3D.map_changed.disconnect(_navigation_server_map_changed)
		target = null
		hide()
		set_physics_process(false)


func _ready() -> void:
	dummy = dummy_scene.instantiate() as Dummy
	assert(dummy, "Dummy scene is incorrect")
	add_child(dummy)
	player = get_tree().get_first_node_in_group("player")
	GlobalSignal.open_store.connect(_open_store)


func _navigation_server_map_changed(_map_rid: RID) -> void:
	set_path()


func set_path() -> void:
	if target:
		return
	navigation_ready = true
	
	var random_choice = npc_choices.pick_random()
	match random_choice:
		NpcChoices.Random:
			target = endPathMarker
		NpcChoices.Pizza_Shop:
			if not is_store_open:
				target = endPathMarker
			else:
				var walk_in_store = randi_range(0, walk_in_store_odds)
				if walk_in_store == 0:
					target = GlobalMarker.restaurant_marker
				else:
					target = endPathMarker
		NpcChoices.Park:
			if GlobalMarker.park_marker_npc:
				target = endPathMarker
			else:
				target = GlobalMarker.park_marker
				GlobalMarker.park_marker_npc = self
	
	navigation_agent.set_target_position(NavigationServer3D.map_get_closest_point(navigation_agent.get_navigation_map(), target.global_position))


#func _process(_delta: float) -> void:
	#var camera = get_viewport().get_camera_3d()
	#if camera:
		#var distance = global_transform.origin.distance_to(camera.global_transform.origin)
		#
		#if distance < 2.0:
			#visible = false
		#else:
			#visible = true


func _physics_process(delta: float) -> void:
	if next_state:
		current_state = next_state
		next_state = NPCState.None
	match current_state:
		NPCState.Idle:
			idle_state(delta)
		NPCState.Walking:
			walking_state(delta)
		NPCState.Sitting:
			sitting_state(delta)
		_:
			pass


func idle_state(_delta:float) -> void:
	velocity = Vector3.ZERO
	dummy.idle_animation()
	if not target:
		get_target(NPCState.Idle)
		return
	if target == GlobalMarker.queue_marker and not has_order:
		pointer.show()
		
		has_order = true
		order_total = 0
		random_food = GlobalVar.get_random_food_by_level(player.level)
		if random_food in [1,2,3]:
			order_total = 5
		else:
			order_total = 10
		var money_payed:int = randi_range(order_total, order_total+8)
		GlobalSignal.process_order.emit(self, money_payed, order_total, random_food)
		%RadialProgressBar.show()
		%Ding.play()
	
	if table and not sitting:
		get_parent().remove_child(self)
		table.chair.add_child(self)
		global_position = table.chair.sitting_marker.global_position
		look_at(table.global_position)
		dummy.sit_chair_animation()
		
		next_state = NPCState.Sitting
		previous_state = current_state
		
		sitting = true
		%RadialProgressBar.show()
	
	if target == endPathMarker:
		enable_npc(false)
	
	if target == GlobalMarker.queue_marker:
		var target_pos = player.global_position
		target_pos.y = global_position.y
		look_at(target_pos)
	
	if target == GlobalMarker.restaurant_marker or target == GlobalMarker.outside_marker \
	or target == GlobalMarker.queue2_marker or target == GlobalMarker.queue3_marker:
		get_target(NPCState.Idle)
		
	if target == GlobalMarker.park_marker:
		var bench_marker = GlobalMarker.park_marker.get_child(0) as Marker3D
		global_position = bench_marker.global_position
		look_at(GlobalMarker.park_marker.global_position)
		dummy.sit_chair_animation()
		next_state = NPCState.Sitting
		previous_state = current_state
		sitting = true
	
func walking_state(delta:float) -> void:
	if not navigation_ready:
		return
	if not navigation_agent.is_navigation_finished():
		var destination = navigation_agent.get_next_path_position()
		var local_destination = destination - global_position
		var direction = local_destination.normalized()
		var new_velocity = direction * speed
		if test_move(transform, new_velocity) and (target == GlobalMarker.queue_marker):
			dummy.idle_animation()
		else:
			look_at_target(destination, delta)
			dummy.walk_animation()
			if navigation_agent.avoidance_enabled:
				navigation_agent.velocity = new_velocity
			else:
				_on_navigation_agent_3d_velocity_computed(new_velocity)
	else:
		next_state = NPCState.Idle
		previous_state = current_state
	
func sitting_state(_delta:float) -> void:
	if not sitting:
		get_target(NPCState.Sitting)
	
func get_target(_current_state:NPCState) -> void:
	if not target:
		set_path()
	else:
		if target == GlobalMarker.outside_marker:
			target = endPathMarker
			navigation_agent.set_target_position(NavigationServer3D.map_get_closest_point(navigation_agent.get_navigation_map(), target.global_position))
		elif target == GlobalMarker.restaurant_marker:
			if not GlobalMarker.queue1_npc:
				GlobalMarker.queue1_npc = self
				target = GlobalMarker.queue_marker
			elif not GlobalMarker.queue2_npc:
				GlobalMarker.queue2_npc = self
				target = GlobalMarker.queue2_marker
			elif not GlobalMarker.queue3_npc:
				GlobalMarker.queue3_npc = self
				target = GlobalMarker.queue3_marker
			else:
				target = endPathMarker
			navigation_agent.set_target_position(NavigationServer3D.map_get_closest_point(navigation_agent.get_navigation_map(), target.global_position))
		elif target == GlobalMarker.queue2_marker:
			if not GlobalMarker.queue1_npc:
				GlobalMarker.queue1_npc = self
				target = GlobalMarker.queue_marker
				%RadialProgressBar.show()
				GlobalMarker.queue2_npc = null
				navigation_agent.set_target_position(NavigationServer3D.map_get_closest_point(navigation_agent.get_navigation_map(), target.global_position))
		elif target == GlobalMarker.queue3_marker:
			if not GlobalMarker.queue2_npc:
				GlobalMarker.queue2_npc = self
				target = GlobalMarker.queue2_marker
				GlobalMarker.queue3_npc = null
				navigation_agent.set_target_position(NavigationServer3D.map_get_closest_point(navigation_agent.get_navigation_map(), target.global_position))
		
	
	if target:
		next_state = NPCState.Walking
		previous_state = _current_state


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false


func _check_for_open_table() -> void:
	if is_waiting_on_table:
		GlobalSignal.get_open_table.emit(self)
		is_waiting_on_table = false

func _process_payment(npc_dummy:NPC_Dummy) -> void:
	if npc_dummy == self:
		%RadialProgressBar.hide()
		GlobalSignal.get_open_table.emit(self)


func _assign_customer_to_table(_table:Table, _npc_dummy:NPC_Dummy) -> void:
	if _npc_dummy != self:
		return
	if not _table:
		is_waiting_on_table = true
		return
	table = _table
	
	GlobalSignal.add_order.emit(table.get_meta("table_id"), random_food)
	GlobalSignal.check_restaurant_food.emit(random_food)
	
	table.npc = self
	table.dialogue_box = dialogue_box
	target = table.chair.sitting_marker
	GlobalMarker.queue1_npc = null
	
	navigation_agent.set_target_position(NavigationServer3D.map_get_closest_point(navigation_agent.get_navigation_map(), target.global_position))
	pointer.hide()
	
	next_state = NPCState.Walking
	previous_state = current_state

func look_at_target(pos: Vector3, delta: float) -> void:
	var direction: Vector3 = global_position.direction_to(pos)
	if direction != Vector3.ZERO:
		var _target: Basis = Basis.looking_at(direction, Vector3.UP)
		basis = basis.slerp(_target, 5 * delta).orthonormalized()

func _remove_customer(_npc_dummy:NPC_Dummy) -> void:
	if self == _npc_dummy:
		has_order = false
		dummy.sit_chair_stand_up()
		table.chair.remove_child(self)
		initial_parent.add_child(self)
		global_transform = table.chair.sitting_marker.global_transform
		look_at(table.global_position)
		table.is_empty = true
		table.npc = null
		await get_tree().create_timer(0.5).timeout
		GlobalSignal.check_for_open_table.emit()
		_leave_restaurant()


func _leave_restaurant() -> void:
	target = GlobalMarker.outside_marker
	navigation_agent.set_target_position(NavigationServer3D.map_get_closest_point(navigation_agent.get_navigation_map(), target.global_position))
	area_col.disabled = true
	table = null
	sitting = false


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	move_and_slide()


func _on_radial_progress_bar_radial_timeout() -> void:
	if sitting:
		GlobalSignal.remove_order_from_list.emit(table.table_id)
		_remove_customer(self)
		player.update_money(-order_total)
	else:
		_leave_restaurant()
		GlobalSignal.remove_order_from_register.emit()
		await get_tree().create_timer(1).timeout
		GlobalMarker.queue1_npc = null


func interact() -> void:
	if is_quest_complete:
		dialogue_box.dialogue_id = DialogueIds.FIND_ITEM_DOUGH
		dialogue_box.show()
	elif has_quest:
		GlobalSignal.update_quest_objective.emit(QuestIds.FIND_ITEM, QuestObjs.BRING_DOUGH)
		if player.get_held_object_mesh_name() == QuestItems.DOUGH:
			is_quest_complete = true
			dialogue_box.current_index += 1
		dialogue_box.dialogue_id = DialogueIds.FIND_ITEM_DOUGH
		dialogue_box.show()
		return
	else:
		has_quest = true
		dialogue_box.dialogue_id = DialogueIds.FIND_ITEM_DOUGH
		dialogue_box.show()
		dialogue_box.current_index += 1
		GlobalSignal.add_quest.emit(QuestIds.FIND_ITEM, QuestItems.DOUGH)


func _open_store() -> void:
	is_store_open = true
