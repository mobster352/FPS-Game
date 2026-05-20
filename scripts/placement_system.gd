extends Node3D
class_name PlacementSystem

signal setup_object_preview(uuid: StringName, original_obj: Node3D, new_obj_path: StringName, _money:int)

#@export var camera: Camera3D
@export var max_distance := 5.0
@export var player: Player
@export var highlight_color: Color = Color(0,0,5,0.35)
@export var restaurant_nav_region: NavigationRegion3D

var toggle_build:bool = false
var objects:Array[Node]

var preview_instance: Node3D
var place_scene_path: StringName
var original_obj: Node3D
var original_obj_parent

var place_scene: PackedScene
var can_place := false
var item_shape: Shape3D
var is_placing := false
var money:int

var is_table:bool = false

var preview_objects_uuids:Array[String] = [
	"uid://bgb0ai3o1lbah",
	"uid://b24sn63vi5kcs",
	"uid://ftktew0563fj",
	"uid://u3r87twoyihh",
	"uid://bnutiphxtceau",
	"uid://etwcw4esf47g",
	"uid://7t2skrh4o8jq"
]
@onready var preview_object_nodes: Node3D = %PreviewObjects
var preview_objects:Dictionary[String,Node3D]


func _ready() -> void:
	objects = get_tree().get_nodes_in_group("placement")
	setup_object_preview.connect(_setup_object_preview)
	
	for uuid:String in preview_objects_uuids:
		var obj:Node3D = load(uuid).instantiate()
		obj.hide()
		preview_object_nodes.add_child(obj)
		preview_objects.set(uuid, obj)

func _process(_delta: float) -> void:
	var build_input = Input.is_action_just_pressed("build")
	var interact = Input.is_action_just_pressed("interact")
	var drop_input = Input.is_action_just_pressed("drop")
	if build_input:
		toggle_build = not toggle_build
	if toggle_build and preview_instance:
		update_preview()
		if is_placing:
			if interact:
				#var is_placed = await confirm_placement()
				var is_placed = confirm_placement()
				if is_placed:
					interact = false
					is_placing = false
			if drop_input:
				cancel_placement()
				drop_input = false
				is_placing = false
		else:
			is_placing = true
	for o in objects:
		if o:
			for mesh in o.get_children():
				if mesh is MeshInstance3D:
					_toggle_build_highlight(mesh.get_active_material(0))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and preview_instance and is_placing:
		if event.is_pressed():
			if event.is_action_pressed("rotate_preview_left"):
				preview_instance.rotate_y(deg_to_rad(10))
			elif event.is_action_pressed("rotate_preview_right"):
				preview_instance.rotate_y(deg_to_rad(-10))


func _toggle_build_highlight(material: StandardMaterial3D) -> void:
	if not material:
		return
	if toggle_build:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = highlight_color
	else:
		material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
		material.albedo_color = Color(1,1,1)


func _setup_object_preview(uuid: StringName, _original_obj: Node3D, new_obj_path: StringName, _money:int) -> void:
	if preview_instance:
		return
	preview_instance = preview_objects.get(uuid)
	original_obj = _original_obj
	place_scene_path = new_obj_path
	toggle_build = true
	money = _money
	start_placement()


func start_placement():
	preview_instance.global_rotation = Vector3.ZERO
	preview_instance.show()
	
	place_scene = load(place_scene_path)
	
	assert(preview_instance.has_node("collider"), "Preview Instance does not have a collider")
	
	var collision_shape_preview_instance = preview_instance.get_node("collider") as CollisionShape3D
	item_shape = collision_shape_preview_instance.shape

	#_make_preview_material(preview_instance)
	
	original_obj_parent = original_obj.get_parent()
	if original_obj is Table:
		is_table = true
		#GlobalSignal.remove_table.emit(original_obj)
	original_obj.queue_free()


func update_preview():
	var space_state = get_world_3d().direct_space_state

	var from = player.camera.global_position
	var forward = -player.camera.global_transform.basis.z
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
	
	var intersect_query = PhysicsShapeQueryParameters3D.new()
	intersect_query.transform = preview_instance.transform
	intersect_query.shape = item_shape
	intersect_query.collision_mask =  (1 << 8 - 1)

	var intersect_hit = space_state.get_rest_info(intersect_query)

	if down_hit and down_hit.position.y < 4.0:
		if intersect_hit:
			can_place = false
		else:
			can_place = true
		preview_instance.global_position = down_hit.position
		#preview_instance.global_rotation.y = player.camera.global_rotation.y
		#var in_nav_region = is_position_in_nav_region(preview_instance.global_position)
		#if not in_nav_region:
			#can_place = false
	else:
		can_place = false

	_update_preview_color(can_place)


func confirm_placement() -> bool:
	if not can_place or not preview_instance:
		return false

	var instance = place_scene.instantiate()
	
	#await get_tree().create_timer(0.1).timeout
	
	original_obj_parent.add_child(instance)
	
	instance.global_transform = preview_instance.global_transform
	
	objects = get_tree().get_nodes_in_group("placement")
	
	cancel_placement()
	
	restaurant_nav_region.bake_navigation_mesh()
	toggle_build = false
	
	player.update_money(money)
	GlobalSignal.check_for_open_table.emit()
	
	
	if is_table:
		GlobalSignal.update_quest_objective.emit(QuestIds.BUY_TABLE, QuestObjs.BUY_TABLE)
	
	return true


func cancel_placement():
	if preview_instance:
		#preview_instance.queue_free()
		preview_instance.hide()
		preview_instance = null
		place_scene_path = ""
		toggle_build = false


#func _make_preview_material(root: Node):
	#for child in root.get_children(true):
		#if child is MeshInstance3D:
			#var mat = StandardMaterial3D.new()
			#mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			#mat.albedo_color = Color(0, 1, 0, 0.35)
			#mat.no_depth_test = true
			#child.material_override = mat


func _update_preview_color(valid: bool):
	var color
	if valid:
		color = Color(0, 1, 0, 0.35)
	else:
		color = Color(1, 0, 0, 0.35)

	for child in preview_instance.find_children("*", "MeshInstance3D", true):
		if child is MeshInstance3D:
			child.material_override.albedo_color = color


func print_objects() -> void:
	print("---------")
	for o in objects:
		print(o)
	print("---------")


func is_position_in_nav_region(target_pos: Vector3) -> bool:
	var map_rid = restaurant_nav_region.get_navigation_map()
	
	var closest_point = NavigationServer3D.map_get_closest_point(map_rid, target_pos)
	
	if target_pos.distance_to(closest_point) > 0.1:
		return false

	# Get the polygon owner (region)
	var region_rid = restaurant_nav_region.get_rid()
	var nav_owner = NavigationServer3D.map_get_closest_point_owner(map_rid, target_pos)

	return nav_owner == region_rid


func sell_table(table:Table) -> void:
	GlobalSignal.remove_table.emit(table)
	table.queue_free()
	toggle_build = false
	player.update_money(25)
