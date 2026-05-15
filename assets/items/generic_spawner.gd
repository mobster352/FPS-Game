extends ObjectSpawner
class_name GenericSpawner

var quest_log:QuestLog

func _ready() -> void:
	super()
	quest_log = get_tree().get_first_node_in_group("quest_log")
	%PizzaLabel.text = item_text + " (" + str(object_array.size()) + "/8)"
	
func _physics_process(_delta: float) -> void:
	%PizzaLabel.text = item_text + " (" + str(object_array.size()) + "/8)"
	%PizzaLabel.hide()

func add_object() -> void:
	var obj = load(mesh_path).instantiate() as Node3D
	if object_array.size() < 4:
		obj.position += _get_next_pos()
	else:
		obj.position += _get_next_pos() + Vector3(0,0.5,0)
	obj.scale = Vector3(0.75,0.75,0.75)
	object_array.append(obj)
	mesh.add_child(obj)
	item.mesh = mesh
	item.set_meta("count", object_array.size())

func remove_object() -> Item:
	if mesh.get_child_count() <= 0:
		return null
	var node = mesh.get_children().pop_back() as Node3D
	node.queue_free()
	object_array.pop_back()
	item.set_meta("count", object_array.size())
	var new_node = load(scene_path).instantiate() as Item
	mesh.add_child(new_node)
	item.mesh = mesh
	return new_node
	
func thief_remove_object() -> void:
	if mesh.get_child_count() <= 0:
		return
	var node = mesh.get_children().pop_back() as Node3D
	node.queue_free()
	object_array.pop_back()
	if is_instance_valid(item):
		item.set_meta("count", object_array.size())


func _on_dough_radius_body_entered(body: Node3D) -> void:
	var parent = body.get_parent()
	if parent.has_meta("name"):
		if parent.get_meta("name") == item_name:
			if object_array.size() < 8:
				if parent is Item:
					if body is RigidBody3D:
						body.freeze = true
					parent.shrink_and_free(0, 0.15)
					add_object()
				else:
					parent.queue_free()
					add_object()
			else:
				if body is RigidBody3D:
					var forward = body.global_transform.basis.z.normalized()
					var throw_strength: float = 1.0
					body.apply_impulse(forward * (throw_strength / body.mass), body.global_position + forward)


func can_interact(player: Player) -> bool:
	if item.in_range:
		%PizzaLabel.show()
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.InteractItem, player.has_held_object(), true)
	return item.in_range
	
func interact(player: Player) -> void:
	if player.has_held_object():
		if player.get_held_object_mesh_name() == mesh_name and object_array.size() < MAX_SIZE:
			add_object()
			var held_obj = player.get_held_object()
			held_obj.queue_free()
	else:
		var obj:Item = remove_object()
		if obj:
			if obj.get_parent():
				obj.get_parent().remove_child(obj)
			obj.pickup(Vector3.ZERO, Vector3(deg_to_rad(10),deg_to_rad(130),deg_to_rad(0)), player)
			if is_instance_valid(quest_log) and item_type == GlobalVar.StoreItem.Dough:
				quest_log.update_quest_objective(QuestResource.QuestIds.MAKE_PIZZA, "Pick Up a dough ball")
			obj.queue_free()

func reticle_color() -> Color:
	return RETICLE_GREEN

func interact2(player: Player) -> void:
	if item.disabled:
		return
	if player.has_held_object():
		player.drop_item()
		return
	if get_parent():
		get_parent().remove_child(self)
	item.pickup(Vector3.ZERO, Vector3(deg_to_rad(-15),deg_to_rad(0),deg_to_rad(0)), player)
	if is_instance_valid(quest_log):
			quest_log.update_quest_objective(QuestResource.QuestIds.MOVE_PRODUCTS, "Pick Up Products")
	item.queue_free()
