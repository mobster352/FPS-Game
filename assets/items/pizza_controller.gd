extends Pizza

@export var pointer: Node3D
@export var mesh_slices: Array[MeshInstance3D]

var restaurant: Restaurant
var quest_log:QuestLog

func _ready() -> void:
	GlobalSignal.drop_food.connect(_drop_food)
	GlobalSignal.pickup_food.connect(_pickup_food)
	GlobalSignal.init_restaurant.connect(_init_restaurant)
	GlobalSignal.toggle_pointer_by_food.connect(_toggle_pointer_by_food)
	quest_log = get_tree().get_first_node_in_group("quest_log")
	
func _process(_delta: float) -> void:
	%PizzaLabel.hide()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true
	elif body.get_parent().has_meta("food_id"):
		if body.get_parent().get_meta("food_id") == whole_pizza_type:
			refill_pizza_slices()
			body.get_parent().queue_free()
			if is_instance_valid(quest_log):
				if quest_log.active_quest_id == Quest.QuestIds.PLACE_PIZZA:
					quest_log.update_quest_objective(Quest.QuestObjs.PLACE_PIZZA_COUNTER)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false


func get_slice() -> Item:
	if pizza_type == GlobalVar.PIZZA_TYPE.PEPPERONI:
		var slice = get_next_slice()
		if slice:
			slice.hide()
			pointer.hide()
			var pizza =  preload("res://assets/items/pepperoni_slice_plate_item.tscn").instantiate() as Item
			add_child(pizza)
			return pizza
	if pizza_type == GlobalVar.PIZZA_TYPE.CHEESE:
		var slice = get_next_slice()
		if slice:
			slice.hide()
			pointer.hide()
			var pizza =  preload("res://assets/items/cheese_slice_plate_item.tscn").instantiate() as Item
			add_child(pizza)
			return pizza
	if pizza_type == GlobalVar.PIZZA_TYPE.MUSHROOM:
		var slice = get_next_slice()
		if slice:
			slice.hide()
			pointer.hide()
			var pizza =  preload("res://assets/items/mushroom_slice_plate_item.tscn").instantiate() as Item
			add_child(pizza)
			return pizza
	return null


func _drop_food(food_id:int) -> void:
	if pizza_type == food_id and restaurant.needs_food(food_id):
		pointer.show()


func _pickup_food(food_id:int) -> void:
	if pizza_type == food_id:
		pointer.hide()


func _init_restaurant(_restaurant:Restaurant) -> void:
	restaurant = _restaurant


func _toggle_pointer_by_food(food_id:int, value:bool) -> void:
	if pizza_type == food_id:
		pointer.visible = value


func can_interact(player: Player) -> bool:
	if in_range:
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.InteractItem, player.has_held_object())
		%PizzaLabel.show()
	return in_range
	
func interact(player: Player) -> void:
	if player.has_held_object():
		player.drop_item()
	var obj = get_slice()
	if not obj:
		return
	if obj.get_parent():
		obj.get_parent().remove_child(obj)
	obj.pickup(Vector3.ZERO, Vector3(deg_to_rad(10),deg_to_rad(130),deg_to_rad(0)), player)
	obj.queue_free()
	
func reticle_color() -> Color:
	return RETICLE_GREEN

func interact2(player: Player) -> void:
	if player.has_held_object():
		player.drop_item()


func get_next_slice() -> MeshInstance3D:
	for slice in mesh_slices:
		if slice.visible:
			return slice
	return null


func refill_pizza_slices() -> void:
	for slice in mesh_slices:
		slice.visible = true
