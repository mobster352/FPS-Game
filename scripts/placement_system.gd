extends Node3D
class_name PlacementSystem

@export var camera: Camera3D
@export var max_distance := 5.0
@export var player: Player
@export var highlight_color: Color = Color(0,0,5,0.35)

var toggle_build:bool = false
var objects:Array[Node]

var place_scene: PackedScene
var preview_instance: Node3D
var can_place := false
var place_scene_item_type: GlobalVar.StoreItem
var item_shape: Shape3D
var place_scene_path: StringName
var item_type: GlobalVar.StoreItem
var is_placing := false

func _ready() -> void:
	objects = get_tree().get_nodes_in_group("placement")

func _process(_delta: float) -> void:
	var build_input = Input.is_action_just_pressed("build")
	if build_input:
		toggle_build = not toggle_build
	for o in objects:
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

func setup_placement(preview_scene: PackedScene, _place_scene_path: StringName, _item_type: GlobalVar.StoreItem) -> void:
	if preview_instance:
		return

	preview_instance = preview_scene.instantiate()
	place_scene_path = _place_scene_path
	item_type = _item_type


func start_placement():
	get_tree().current_scene.add_child(preview_instance)
	
	place_scene = load(place_scene_path)
	place_scene_item_type = item_type
	
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
	intersect_query.collision_mask =  (1 << 4 - 1) | (1 << 6 - 1)

	var intersect_hit = space_state.get_rest_info(intersect_query)
	#print(intersect_hit)

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
	if not can_place or not preview_instance or not player.has_held_object():
		return false

	var instance = place_scene.instantiate()
	if instance.has_node("body/Interactable"):
		var interactable = instance.get_node("body/Interactable")
		if interactable is ObjectSpawner:
			interactable.item_type = place_scene_item_type

	var child_mesh = player.item_slot.get_child(0)
	if child_mesh:
		if child_mesh.has_meta("count"):
			instance.set_meta("count", child_mesh.get_meta("count"))

		if child_mesh.has_meta("food_id"):
				instance.set_meta("food_id", child_mesh.get_meta("food_id"))
				instance.mesh.set_meta("food_id", child_mesh.get_meta("food_id"))
		
		if child_mesh.has_meta("pizza"):
			instance.mesh.set_meta("pizza", child_mesh.get_meta("pizza"))
		
	if instance.has_meta("food_id"):
		var food_id = instance.get_meta("food_id")
		if food_id:
			GlobalSignal.drop_food.emit(food_id)
			GlobalSignal.check_restaurant_food.emit(food_id)
	elif instance.has_meta("plate_dirty"):
		instance.pointer.show()
		GlobalSignal.toggle_pointer.emit("sink", false)
			
	instance.global_transform = preview_instance.global_transform
	
	if instance is PizzaBoxStack:
		instance.num_pizza_boxes = preview_instance.num_pizza_boxes
	
	get_tree().current_scene.add_child(instance)

	cancel_placement(true)
	return true


func cancel_placement(remove_held_obj: bool):
	if preview_instance:
		preview_instance.queue_free()
		preview_instance = null
		place_scene_item_type = GlobalVar.StoreItem.None
		if player.has_held_object() and remove_held_obj:
			var child_mesh = player.item_slot.get_child(0)
			if child_mesh:
				player.item_slot.remove_child(child_mesh)
				child_mesh.queue_free()
		place_scene_path = ""
		item_type = GlobalVar.StoreItem.None


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
			
	if preview_instance is PizzaBoxStack:
		for m in preview_instance.pizza_boxes.get_children():
			if m.get_child_count() > 0:
				if m.get_child(0) is MeshInstance3D:
					var n = m.get_child(0) as MeshInstance3D
					n.material_override = StandardMaterial3D.new()
					n.material_override.albedo_color = color
			for c in m.get_children():
				if c.get_child_count() > 0:
					if c.get_child(0) is MeshInstance3D:
						var n = c.get_child(0) as MeshInstance3D
						n.material_override = StandardMaterial3D.new()
						n.material_override.albedo_color = color
