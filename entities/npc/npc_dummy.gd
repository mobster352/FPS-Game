extends CharacterBody3D
class_name NPC_Dummy

@export var dialogue_box: DialogueBox
@export var speed := 1.5
@export var area_col: CollisionShape3D
@export var navigation_agent: NavigationAgent3D
@export var start_target: Marker3D
@export var pointer: Node3D

@onready var dummy = $Dummy
@export var level_ui: Level_UI
@export var walk_in_store_odds := 16

@onready var initial_parent = get_parent()

var target: Marker3D
var table: Table
var in_range := false
var has_order := false
var sitting := false
var navigation_ready := false

func _ready() -> void:
	GlobalSignal.assign_customer_to_table.connect(_assign_customer_to_table)
	GlobalSignal.remove_customer.connect(_remove_customer)
	NavigationServer3D.map_changed.connect(_navigation_server_map_changed)
	
func _navigation_server_map_changed(_map_rid: RID) -> void:
	navigation_ready = true
	if start_target:
		target = start_target
	if navigation_agent.get_navigation_map() and target:
		navigation_agent.set_target_position(NavigationServer3D.map_get_closest_point(navigation_agent.get_navigation_map(), target.global_position))
	else:
		navigation_agent.set_target_position(NavigationServer3D.map_get_random_point(navigation_agent.get_navigation_map(), 1, true))

func _physics_process(delta: float) -> void:
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
		velocity = Vector3.ZERO
		if target:
			if target == GlobalMarker.queue_marker and area_col.disabled:
				area_col.disabled = false
				pointer.show()
			if table and not sitting:
				get_parent().remove_child(self)
				table.chair.add_child(self)
				global_position = table.chair.sitting_marker.global_position
				look_at(table.global_position)
				dummy.sit_chair_animation()
				sitting = true
			if not sitting:
				dummy.idle_animation()
			if target == GlobalMarker.outside_marker:
				#navigation_agent.set_navigation_layer_value(1,true)
				#navigation_agent.set_navigation_layer_value(2,false)
				navigation_agent.set_target_position(NavigationServer3D.map_get_random_point(navigation_agent.get_navigation_map(), 1, true))
				target = null
				#set_collision_mask_value(6, false)
			elif target == GlobalMarker.restaurant_marker:
				#navigation_agent.set_navigation_layer_value(1,false)
				#navigation_agent.set_navigation_layer_value(2,true)
				target = GlobalMarker.queue_marker
				#set_collision_mask_value(6, true)
				navigation_agent.set_target_position(NavigationServer3D.map_get_closest_point(navigation_agent.get_navigation_map(), target.global_position))
		else:
			var go_to_restaurant_chance = randi_range(0,walk_in_store_odds)
			if go_to_restaurant_chance == 0 and level_ui.hours >= 6 and level_ui.hours < 18:
				target = GlobalMarker.restaurant_marker
				navigation_agent.set_target_position(NavigationServer3D.map_get_closest_point(navigation_agent.get_navigation_map(), target.global_position))
			else:
				navigation_agent.set_target_position(NavigationServer3D.map_get_random_point(navigation_agent.get_navigation_map(), 1, true))

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false


func interact() -> void:
	if not has_order:
		GlobalSignal.get_open_table.emit(self)

func _assign_customer_to_table(_table:Table,_npc_dummy:NPC_Dummy) -> void:
	if _npc_dummy == self:
		table = _table
		var random_food = randi_range(1,6)
		GlobalSignal.add_order.emit(table.get_meta("table_id"), random_food)
		GlobalSignal.check_restaurant_food.emit(random_food)
		has_order = true
		dialogue_box.text = dialogue_box.get_order_text() + GlobalVar.get_food(random_food).food_name
		dialogue_box.show()
		table.npc = self
		table.dialogue_box = dialogue_box
		target = table.chair.sitting_marker
		navigation_agent.set_target_position(NavigationServer3D.map_get_closest_point(navigation_agent.get_navigation_map(), target.global_position))
		pointer.hide()

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
		global_position = table.chair.sitting_marker.global_position
		await get_tree().create_timer(0.5).timeout
		target = GlobalMarker.outside_marker
		navigation_agent.set_target_position(NavigationServer3D.map_get_closest_point(navigation_agent.get_navigation_map(), target.global_position))
		area_col.disabled = true
		table = null
		sitting = false


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	move_and_slide()
