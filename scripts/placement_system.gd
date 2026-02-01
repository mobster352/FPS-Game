extends Node3D
class_name PlacementSystem

signal setup_object_preview(uuid: StringName, original_obj: Node3D, new_obj_path: StringName)

@export var camera: Camera3D
@export var max_distance := 5.0
@export var player: Player
@export var highlight_color: Color = Color(0,0,5,0.35)

var toggle_build:bool = false
var objects:Array[Node]

var preview_instance: Node3D
var place_scene_path: StringName
var original_obj: Node3D

var place_scene: PackedScene
var can_place := false
var item_shape: Shape3D
var is_placing := false

func _ready() -> void:
	objects = get_tree().get_nodes_in_group("placement")
	setup_object_preview.connect(_setup_object_preview)

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
				var is_placed = await confirm_placement()
				if is_placed:
					interact = false
					is_placing = false
			if drop_input:
				cancel_placement()
				drop_input = false
				is_placing = false
		else:
			is_placing = true
	else:
		for o in objects:
			if o:
				for mesh in o.get_children():
					if mesh is MeshInstance3D:
						_toggle_build_highlight(mesh.get_active_material(0))


func _toggle_build_highlight(material: StandardMaterial3D) -> void:
	if toggle_build:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = highlight_color
	else:
		material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
		material.albedo_color = Color(1,1,1)


func _setup_object_preview(uuid: StringName, _original_obj: Node3D, new_obj_path: StringName) -> void:
	if preview_instance:
		return
	preview_instance = load(uuid).instantiate()
	original_obj = _original_obj
	place_scene_path = new_obj_path
	start_placement()


func start_placement():
	get_tree().current_scene.add_child(preview_instance)
	
	place_scene = load(place_scene_path)
	
	assert(preview_instance.has_node("collider"), "Preview Instance does not have a collider")
	
	var collision_shape_preview_instance = preview_instance.get_node("collider") as CollisionShape3D
	item_shape = collision_shape_preview_instance.shape

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
		preview_instance.global_rotation.y = camera.global_rotation.y
	else:
		can_place = false

	_update_preview_color(can_place)


func confirm_placement() -> bool:
	if not can_place or not preview_instance:
		return false

	var instance = place_scene.instantiate()
	
	var original_obj_parent = original_obj.get_parent()
	original_obj.queue_free()
	
	await get_tree().create_timer(0.1).timeout
	
	original_obj_parent.add_child(instance)
	
	instance.global_transform = preview_instance.global_transform
	
	objects = get_tree().get_nodes_in_group("placement")
	
	cancel_placement()
	return true


func cancel_placement():
	if preview_instance:
		preview_instance.queue_free()
		preview_instance = null
		place_scene_path = ""


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


func print_objects() -> void:
	print("---------")
	for o in objects:
		print(o)
	print("---------")
