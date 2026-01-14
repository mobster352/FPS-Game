extends ObjectSpawner

const DOUGH_PATH = "res://assets/kaykit/restaurant/food_ingredient_dough.gltf"

func _ready() -> void:
	add_object()
	add_object()
	add_object()
	
func _process(_delta: float) -> void:
	pass

func add_object() -> void:
	var dough = preload(DOUGH_PATH).instantiate() as Node3D
	if object_array.size() < 4:
		dough.position += _get_next_pos()
	else:
		dough.position += _get_next_pos() + Vector3(0,0.5,0)
	object_array.append(dough)
	add_child(dough)

func remove_object() -> Item:
	if get_child_count() <= 2:
		return null
	var node = get_children().pop_back() as Node3D
	node.queue_free()
	object_array.pop_back()
	return preload("res://assets/environment/restaurant/food_ingredient_dough.tscn").instantiate()

func _get_next_pos() -> Vector3:
	var index = posmod(object_array.size(), 4)
	match index:
		0:
			return TOP_LEFT_POS
		1:
			return TOP_RIGHT_POS
		2:
			return BOTTOM_LEFT_POS
		3:
			return BOTTOM_RIGHT_POS
	return Vector3.ZERO


func _on_dough_radius_body_entered(body: Node3D) -> void:
	var parent = body.get_parent()
	if parent.has_meta("name"):
		if parent.get_meta("name") == "dough":
			parent.queue_free()
			add_object()
