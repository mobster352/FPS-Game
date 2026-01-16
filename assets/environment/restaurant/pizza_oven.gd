extends Node3D
class_name PizzaOven

@export var speed := 1.5
@export var pizza_oven_door_mesh: MeshInstance3D
@export var pizza_slot_top: Node3D
@export var pizza_slot_bottom: Node3D
@export var cook_timer: Timer

var in_range := false
var is_open := false
var interact_door := false
var elapsed := 0.0
var is_locked := false

func _process(delta: float) -> void:
	if elapsed >= 1.0:
		interact_door = false
		is_open = not is_open
		if not is_open:
			is_locked = true
			cook_timer.start()
		elapsed = 0.0
	if interact_door:
		if is_open:
			pizza_oven_door_mesh.basis = lerp(pizza_oven_door_mesh.basis,pizza_oven_door_mesh.basis.rotated(Vector3.RIGHT, deg_to_rad(-90)).orthonormalized(), speed * delta)
		else:
			pizza_oven_door_mesh.basis = lerp(pizza_oven_door_mesh.basis,pizza_oven_door_mesh.basis.rotated(Vector3.RIGHT, deg_to_rad(90)).orthonormalized(), speed * delta)
		elapsed += speed * delta


func open_door() -> void:
	interact_door = true


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false


func _on_pizza_area_body_entered(body: Node3D) -> void:
	if body.has_meta("name") and body.get_meta("name") == "dough_base" and is_open:
		var item = body.get_parent() as Item
		if item:
			if pizza_slot_top.get_child_count() == 0:
				var mesh = item.get_node("body/mesh")
				mesh.position = Vector3.ZERO
				mesh.rotation = Vector3.ZERO
				if mesh.get_parent():
					mesh.get_parent().remove_child(mesh)
				if item.mesh.has_meta("toppings"):
					if item.mesh.get_meta("toppings").has("food_ingredient_pepperoni_mesh") and item.mesh.get_meta("toppings").has("food_ingredient_tomato_mesh") and item.mesh.get_meta("toppings").has("food_ingredient_cheese_mesh"):
						pizza_slot_top.set_meta("pizza", GlobalVar.PIZZA_TYPE.PEPPERONI)
					elif item.mesh.get_meta("toppings").has("food_ingredient_mushroom_mesh") and item.mesh.get_meta("toppings").has("food_ingredient_tomato_mesh") and item.mesh.get_meta("toppings").has("food_ingredient_cheese_mesh"):
						pizza_slot_top.set_meta("pizza", GlobalVar.PIZZA_TYPE.MUSHROOM)
					elif item.mesh.get_meta("toppings").has("food_ingredient_cheese_mesh") and item.mesh.get_meta("toppings").has("food_ingredient_tomato_mesh") and not item.mesh.get_meta("toppings").has("food_ingredient_pepperoni_mesh") and not item.mesh.get_meta("toppings").has("food_ingredient_mushroom_mesh"):
						pizza_slot_top.set_meta("pizza", GlobalVar.PIZZA_TYPE.CHEESE)
					else:
						pizza_slot_top.set_meta("pizza", GlobalVar.PIZZA_TYPE.NONE)
				pizza_slot_top.add_child(mesh)
			elif pizza_slot_bottom.get_child_count() == 0:
				var mesh = item.get_node("body/mesh")
				mesh.position = Vector3.ZERO
				mesh.rotation = Vector3.ZERO
				if mesh.get_parent():
					mesh.get_parent().remove_child(mesh)
				if item.mesh.has_meta("toppings"):
					if item.mesh.get_meta("toppings").has("food_ingredient_pepperoni_mesh") and item.mesh.get_meta("toppings").has("food_ingredient_tomato_mesh") and item.mesh.get_meta("toppings").has("food_ingredient_cheese_mesh"):
						pizza_slot_bottom.set_meta("pizza", GlobalVar.PIZZA_TYPE.PEPPERONI)
					elif item.mesh.get_meta("toppings").has("food_ingredient_mushroom_mesh") and item.mesh.get_meta("toppings").has("food_ingredient_tomato_mesh") and item.mesh.get_meta("toppings").has("food_ingredient_cheese_mesh"):
						pizza_slot_bottom.set_meta("pizza", GlobalVar.PIZZA_TYPE.MUSHROOM)
					elif item.mesh.get_meta("toppings").has("food_ingredient_cheese_mesh") and item.mesh.get_meta("toppings").has("food_ingredient_tomato_mesh") and not item.mesh.get_meta("toppings").has("food_ingredient_pepperoni_mesh") and not item.mesh.get_meta("toppings").has("food_ingredient_mushroom_mesh"):
						pizza_slot_bottom.set_meta("pizza", GlobalVar.PIZZA_TYPE.CHEESE)
					else:
						pizza_slot_bottom.set_meta("pizza", GlobalVar.PIZZA_TYPE.NONE)
				pizza_slot_bottom.add_child(mesh)
			item.shrink_and_free(0, 0.25)


func _on_cook_timer_timeout() -> void:
	if pizza_slot_top.get_child_count() == 1:
		pizza_slot_top.get_child(0).queue_free()
		
		var pizza
		if pizza_slot_top.has_meta("pizza"):
			if pizza_slot_top.get_meta("pizza") == GlobalVar.PIZZA_TYPE.PEPPERONI:
				pizza = preload("res://assets/items/food_pizza_pepperoni_plated.tscn").instantiate() as Item
				pizza.scale = Vector3(0.8,0.8,0.8)
			elif pizza_slot_top.get_meta("pizza") == GlobalVar.PIZZA_TYPE.MUSHROOM:
				pizza = preload("res://assets/items/food_pizza_mushroom_plated.tscn").instantiate() as Item
				pizza.scale = Vector3(0.8,0.8,0.8)
			elif pizza_slot_top.get_meta("pizza") == GlobalVar.PIZZA_TYPE.CHEESE:
				pizza = preload("res://assets/items/food_pizza_cheese_plated.tscn").instantiate() as Item
				pizza.scale = Vector3(0.8,0.8,0.8)

			if pizza:
				pizza.rigid_body.freeze = true
				pizza_slot_top.add_child(pizza)

	if pizza_slot_bottom.get_child_count() == 1:
		pizza_slot_bottom.get_child(0).queue_free()
		
		var pizza
		if pizza_slot_bottom.has_meta("pizza"):
			if pizza_slot_bottom.get_meta("pizza") == GlobalVar.PIZZA_TYPE.PEPPERONI:
				pizza = preload("res://assets/items/food_pizza_pepperoni_plated.tscn").instantiate() as Item
				pizza.scale = Vector3(0.8,0.8,0.8)
			elif pizza_slot_bottom.get_meta("pizza") == GlobalVar.PIZZA_TYPE.MUSHROOM:
				pizza = preload("res://assets/items/food_pizza_mushroom_plated.tscn").instantiate() as Item
				pizza.scale = Vector3(0.8,0.8,0.8)
			elif pizza_slot_bottom.get_meta("pizza") == GlobalVar.PIZZA_TYPE.CHEESE:
					pizza = preload("res://assets/items/food_pizza_cheese_plated.tscn").instantiate() as Item
					pizza.scale = Vector3(0.8,0.8,0.8)

		if pizza:
			pizza.rigid_body.freeze = true
			pizza_slot_bottom.add_child(pizza)

	is_locked = false
