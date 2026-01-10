extends CharacterBody3D
class_name NPC_Dummy

@export var dialogue_box: DialogueBox
@export var target: Marker3D
@export var outside: Marker3D
@export var speed := 100.0
@export var area_col: CollisionShape3D
@export var navigation_agent: NavigationAgent3D

@onready var dummy = $Dummy

var table: Table
var in_range := false
var has_order := false
var sitting := false
var navigation_ready := false

func _ready() -> void:
	GlobalSignal.assign_customer_to_table.connect(_assign_customer_to_table)
	GlobalSignal.remove_customer.connect(_remove_customer)
	NavigationServer3D.map_changed.connect(_navigation_server_map_changed)
	navigation_agent.target_reached.connect(_target_reached)
	
func _navigation_server_map_changed(_map_rid: RID) -> void:
	navigation_ready = true
	navigation_agent.set_target_position(NavigationServer3D.map_get_closest_point(navigation_agent.get_navigation_map(), target.global_position))

func _physics_process(delta: float) -> void:
	if not navigation_ready:
		return
	var destination = navigation_agent.get_next_path_position()
	if global_position.distance_to(destination) > 0.0:
		var local_destination = destination - global_position
		var direction = local_destination.normalized()
		if global_position.distance_to(navigation_agent.get_final_position()) > navigation_agent.target_desired_distance:
			velocity = direction * speed * delta
			look_at_target(destination, delta)
			dummy.walk_animation()
			move_and_slide()
		else:
			rotate_to_target(target.rotation, delta)
			if area_col.disabled:
				area_col.disabled = false
			if table and not sitting:
				get_parent().remove_child(self)
				table.chair.sitting_marker.add_child(self)
				position = Vector3.ZERO
				dummy.sit_chair_animation()
				sitting = true
			if not sitting:
				dummy.idle_animation()

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
		var random_food = randi_range(0,2)
		GlobalSignal.add_order.emit(table.get_meta("table_id"), random_food)
		has_order = true
		dialogue_box.text = dialogue_box.get_order_text() + GlobalVar.get_food(random_food).food_name
		dialogue_box.show()
		table.npc = self
		table.dialogue_box = dialogue_box
		target = table.chair.sitting_marker
		navigation_agent.set_target_position(NavigationServer3D.map_get_closest_point(navigation_agent.get_navigation_map(), target.global_position))


func look_at_target(pos: Vector3, delta: float) -> void:
	var direction: Vector3 = global_position.direction_to(pos)
	if direction != Vector3.ZERO:
		var _target: Basis = Basis.looking_at(direction, Vector3.UP)
		basis = basis.slerp(_target, 5 * delta).orthonormalized()
		
func rotate_to_target(rot: Vector3, delta: float) -> void:
	basis = basis.slerp(Basis.from_euler(rot), 5 * delta).orthonormalized()

func _remove_customer(_npc_dummy:NPC_Dummy) -> void:
	if self == _npc_dummy:
		has_order = false
		dummy.sit_chair_stand_up()
		await get_tree().create_timer(0.5).timeout
		target = outside
		navigation_agent.set_target_position(NavigationServer3D.map_get_closest_point(navigation_agent.get_navigation_map(), target.global_position))
		area_col.disabled = true
		var new_parent = get_parent().get_parent().get_parent()
		table.chair.sitting_marker.remove_child(self)
		new_parent.add_child(self)
		position = table.chair.position + Vector3(0,0,-0.5)
		table = null
		sitting = false


func _target_reached() -> void:
	pass
