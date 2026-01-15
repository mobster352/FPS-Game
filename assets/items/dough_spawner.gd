extends ObjectSpawner

const DOUGH_PATH = "res://assets/kaykit/restaurant/food_ingredient_dough.gltf"

func _ready() -> void:
	if item.has_meta("count"):
		for i in range(item.get_meta("count")):
			add_object()
			item.set_meta("count", object_array.size())
	
func _process(_delta: float) -> void:
	pass

func add_object() -> void:
	var dough = preload(DOUGH_PATH).instantiate() as Node3D
	if object_array.size() < 4:
		dough.position += _get_next_pos()
	else:
		dough.position += _get_next_pos() + Vector3(0,0.5,0)
	object_array.append(dough)
	mesh.add_child(dough)
	item.set_meta("count", object_array.size())

func remove_object() -> Item:
	if mesh.get_child_count() <= 0:
		return null
	var node = mesh.get_children().pop_back() as Node3D
	node.queue_free()
	object_array.pop_back()
	item.set_meta("count", object_array.size())
	var new_node = preload("res://assets/environment/restaurant/food_ingredient_dough.tscn").instantiate() as Item
	mesh.add_child(new_node)
	return new_node


func _on_dough_radius_body_entered(body: Node3D) -> void:
	var parent = body.get_parent()
	if parent.has_meta("name"):
		if parent.get_meta("name") == "dough":
			if object_array.size() < 8:
				if parent is Item:
					if body is RigidBody3D:
						body.freeze = true
					parent.shrink_and_free(0)
					if not parent.disabled:
						add_object()
						parent.disabled = true
				else:
					parent.queue_free()
					add_object()
			else:
				if body is RigidBody3D:
					var forward = body.global_transform.basis.z.normalized()
					var throw_strength: float = 1.0
					body.apply_impulse(forward * (throw_strength / body.mass), body.global_position + forward)


func can_interact() -> bool:
	return item.in_range
	
func interact(player: Player) -> void:
	var obj = remove_object()
	if obj:
		if player.item_slot.get_child_count() > 0:
			player.drop_item()
		if obj.get_parent():
			obj.get_parent().remove_child(obj)
		obj.pickup(Vector3.ZERO, Vector3(deg_to_rad(10),deg_to_rad(130),deg_to_rad(0)))
		obj.queue_free()
	
func reticle_color() -> Color:
	return RETICLE_GREEN
