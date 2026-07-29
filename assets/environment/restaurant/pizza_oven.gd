extends Node3D
class_name PizzaOven

@export var speed := 1.5
@export var pizza_oven_door_mesh: MeshInstance3D
@export var pizza_slot_top: Node3D
@export var pizza_slot_bottom: Node3D
@export var cook_timer: Timer
@export var oven_audio: AudioStreamPlayer3D
@export var oven_ding_audio: AudioStreamPlayer3D

var in_range := false
var is_open := false
var interact_door := false
var elapsed := 0.0
var is_locked := false

var pepperoni_toppings:Array[StringName] = [
	"food_ingredient_tomato_mesh",
	"food_ingredient_cheese_mesh",
	"food_ingredient_pepperoni_mesh"
]
var cheese_toppings:Array[StringName] = [
	"food_ingredient_tomato_mesh",
	"food_ingredient_cheese_mesh"
]
var mushroom_toppings:Array[StringName] = [
	"food_ingredient_tomato_mesh",
	"food_ingredient_cheese_mesh",
	"food_ingredient_mushroom_mesh"
]
var supreme_toppings:Array[StringName] = [
	"food_ingredient_tomato_mesh",
	"food_ingredient_cheese_mesh",
	"food_ingredient_pepperoni_mesh",
	"food_ingredient_mushroom_mesh"
]

func _ready() -> void:
	pepperoni_toppings.sort()
	cheese_toppings.sort()
	mushroom_toppings.sort()
	supreme_toppings.sort()

func _process(delta: float) -> void:
	if elapsed >= 1.0:
		interact_door = false
		is_open = not is_open
		if not is_open and (pizza_slot_top.get_child_count() > 0 or pizza_slot_bottom.get_child_count() > 0):
			is_locked = true
			cook_timer.start()
			oven_audio.play()
		elapsed = 0.0
	if interact_door:
		if is_open:
			pizza_oven_door_mesh.basis = lerp(pizza_oven_door_mesh.basis,pizza_oven_door_mesh.basis.rotated(Vector3.RIGHT, deg_to_rad(-90)).orthonormalized(), speed * delta)
		else:
			pizza_oven_door_mesh.basis = lerp(pizza_oven_door_mesh.basis,pizza_oven_door_mesh.basis.rotated(Vector3.RIGHT, deg_to_rad(90)).orthonormalized(), speed * delta)
		elapsed += speed * delta


func toggle_door() -> void:
	interact_door = true


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false


func add_pizza_to_oven(mesh:MeshInstance3D) -> void:
	if not mesh.has_meta("toppings"):
		return
	var toppings:Array[StringName] = mesh.get_meta("toppings")
	
	if pizza_slot_top.get_child_count() == 0:
		mesh.position = Vector3.ZERO
		mesh.rotation = Vector3.ZERO
		if mesh.get_parent():
			mesh.get_parent().remove_child(mesh)
		var sorted_toppings:Array = toppings.duplicate()
		sorted_toppings.sort()
		if sorted_toppings == pepperoni_toppings:
			pizza_slot_top.set_meta("pizza", GlobalVar.PIZZA_TYPE.PEPPERONI)
		elif sorted_toppings == mushroom_toppings:
			pizza_slot_top.set_meta("pizza", GlobalVar.PIZZA_TYPE.MUSHROOM)
		elif sorted_toppings == cheese_toppings:
			pizza_slot_top.set_meta("pizza", GlobalVar.PIZZA_TYPE.CHEESE)
			GlobalSignal.update_quest_objective.emit(QuestIds.MAKE_PIZZA, QuestObjs.PLACE_PIZZA_OVEN)
		else:
			pizza_slot_top.set_meta("pizza", GlobalVar.PIZZA_TYPE.NONE)
		mesh.set_surface_override_material(0, null)
		for child_mesh in mesh.get_children():
			if child_mesh.get_child_count() > 0:
				child_mesh.get_child(0).set_surface_override_material(0, null)
		pizza_slot_top.add_child(mesh)
	elif pizza_slot_bottom.get_child_count() == 0:
		mesh.position = Vector3.ZERO
		mesh.rotation = Vector3.ZERO
		if mesh.get_parent():
			mesh.get_parent().remove_child(mesh)
		var sorted_toppings = toppings.duplicate()
		sorted_toppings.sort()
		if sorted_toppings == pepperoni_toppings:
			pizza_slot_bottom.set_meta("pizza", GlobalVar.PIZZA_TYPE.PEPPERONI)
		elif sorted_toppings == mushroom_toppings:
			pizza_slot_bottom.set_meta("pizza", GlobalVar.PIZZA_TYPE.MUSHROOM)
		elif sorted_toppings == cheese_toppings:
			pizza_slot_bottom.set_meta("pizza", GlobalVar.PIZZA_TYPE.CHEESE)
			GlobalSignal.update_quest_objective.emit(QuestIds.MAKE_PIZZA, QuestObjs.PLACE_PIZZA_OVEN)
		else:
			pizza_slot_bottom.set_meta("pizza", GlobalVar.PIZZA_TYPE.NONE)
		mesh.set_surface_override_material(0, null)
		for child_mesh in mesh.get_children():
			if child_mesh.get_child_count() > 0:
				child_mesh.get_child(0).set_surface_override_material(0, null)
		pizza_slot_bottom.add_child(mesh)


#func _on_pizza_area_body_entered(body: Node3D) -> void:
	#if body.has_meta("name") and body.get_meta("name") == "dough_base" and is_open:
		#var item = body.get_parent() as Item
		#if item:
			#if pizza_slot_top.get_child_count() == 0:
				#var mesh = item.get_node("body/mesh")
				#mesh.position = Vector3.ZERO
				#mesh.rotation = Vector3.ZERO
				#if mesh.get_parent():
					#mesh.get_parent().remove_child(mesh)
				#if item.mesh.has_meta("toppings"):
					#if item.mesh.get_meta("toppings").has("food_ingredient_pepperoni_mesh") and item.mesh.get_meta("toppings").has("food_ingredient_tomato_mesh") and item.mesh.get_meta("toppings").has("food_ingredient_cheese_mesh"):
						#pizza_slot_top.set_meta("pizza", GlobalVar.PIZZA_TYPE.PEPPERONI)
					#elif item.mesh.get_meta("toppings").has("food_ingredient_mushroom_mesh") and item.mesh.get_meta("toppings").has("food_ingredient_tomato_mesh") and item.mesh.get_meta("toppings").has("food_ingredient_cheese_mesh"):
						#pizza_slot_top.set_meta("pizza", GlobalVar.PIZZA_TYPE.MUSHROOM)
					#elif item.mesh.get_meta("toppings").has("food_ingredient_cheese_mesh") and item.mesh.get_meta("toppings").has("food_ingredient_tomato_mesh") and not item.mesh.get_meta("toppings").has("food_ingredient_pepperoni_mesh") and not item.mesh.get_meta("toppings").has("food_ingredient_mushroom_mesh"):
						#pizza_slot_top.set_meta("pizza", GlobalVar.PIZZA_TYPE.CHEESE)
						#GlobalSignal.update_quest_objective.emit(QuestIds.MAKE_PIZZA, QuestObjs.PLACE_PIZZA_OVEN)
					#else:
						#pizza_slot_top.set_meta("pizza", GlobalVar.PIZZA_TYPE.NONE)
				#pizza_slot_top.add_child(mesh)
			#elif pizza_slot_bottom.get_child_count() == 0:
				#var mesh = item.get_node("body/mesh")
				#mesh.position = Vector3.ZERO
				#mesh.rotation = Vector3.ZERO
				#if mesh.get_parent():
					#mesh.get_parent().remove_child(mesh)
				#if item.mesh.has_meta("toppings"):
					#if item.mesh.get_meta("toppings").has("food_ingredient_pepperoni_mesh") and item.mesh.get_meta("toppings").has("food_ingredient_tomato_mesh") and item.mesh.get_meta("toppings").has("food_ingredient_cheese_mesh"):
						#pizza_slot_bottom.set_meta("pizza", GlobalVar.PIZZA_TYPE.PEPPERONI)
					#elif item.mesh.get_meta("toppings").has("food_ingredient_mushroom_mesh") and item.mesh.get_meta("toppings").has("food_ingredient_tomato_mesh") and item.mesh.get_meta("toppings").has("food_ingredient_cheese_mesh"):
						#pizza_slot_bottom.set_meta("pizza", GlobalVar.PIZZA_TYPE.MUSHROOM)
					#elif item.mesh.get_meta("toppings").has("food_ingredient_cheese_mesh") and item.mesh.get_meta("toppings").has("food_ingredient_tomato_mesh") and not item.mesh.get_meta("toppings").has("food_ingredient_pepperoni_mesh") and not item.mesh.get_meta("toppings").has("food_ingredient_mushroom_mesh"):
						#pizza_slot_bottom.set_meta("pizza", GlobalVar.PIZZA_TYPE.CHEESE)
						#GlobalSignal.update_quest_objective.emit(QuestIds.MAKE_PIZZA, QuestObjs.PLACE_PIZZA_OVEN)
					#else:
						#pizza_slot_bottom.set_meta("pizza", GlobalVar.PIZZA_TYPE.NONE)
				#pizza_slot_bottom.add_child(mesh)
			#item.queue_free()


func _on_cook_timer_timeout() -> void:
	oven_audio.stop()
	oven_ding_audio.play()
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


func has_open_pizza_slot() -> bool:
	if pizza_slot_top.get_child_count() > 0 and pizza_slot_bottom.get_child_count() > 0:
		return false
	return true
