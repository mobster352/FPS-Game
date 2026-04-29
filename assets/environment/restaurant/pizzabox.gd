extends Item
class_name PizzaBox

const MAX_STACK_SIZE := 10

@export var lid: MeshInstance3D
@export var speed := 1.5
@export var pizza_slot: Node3D

@onready var PIZZABOX_STACK = preload("uid://dp8cybb476vqi")

var is_open := false
var is_cook := false
var is_interact := false
var elapsed := 0.0

func _ready() -> void:
	super._ready()
	if mesh.has_meta("pizza"):
		var pizza_type:GlobalVar.PIZZA_TYPE = mesh.get_meta("pizza")
		if pizza_type == GlobalVar.PIZZA_TYPE.PEPPERONI:
			var pizza = preload("res://assets/kaykit/restaurant/food_pizza_pepperoni_plated.gltf").instantiate() as Node3D
			pizza.scale = Vector3(0.8,0.8,0.8)
			pizza_slot.add_child(pizza)
		if pizza_type == GlobalVar.PIZZA_TYPE.MUSHROOM:
			var pizza = preload("res://assets/kaykit/restaurant/food_pizza_mushroom_plated.gltf").instantiate() as Node3D
			pizza.scale = Vector3(0.8,0.8,0.8)
			pizza_slot.add_child(pizza)
		if pizza_type == GlobalVar.PIZZA_TYPE.CHEESE:
			var pizza = preload("res://assets/kaykit/restaurant/food_pizza_cheese_plated.gltf").instantiate() as Node3D
			pizza.scale = Vector3(0.8,0.8,0.8)
			pizza_slot.add_child(pizza)

func _process(delta: float) -> void:
	if elapsed >= 1.0:
		is_cook = false
		is_open = not is_open
		elapsed = 0.0
	if is_cook:
		if is_open:
			lid.basis = lerp(lid.basis,lid.basis.rotated(Vector3.RIGHT, deg_to_rad(90)).orthonormalized(), speed * delta)
		else:
			lid.basis = lerp(lid.basis,lid.basis.rotated(Vector3.RIGHT, deg_to_rad(-90)).orthonormalized(), speed * delta)
		elapsed += speed * delta

func interact(_player: Player) -> void:
	if disabled:
		return
	if player.has_held_object():
		var held_obj:Node3D = player.get_held_object()
		if held_obj.has_meta("pizzaboxes"):
			var num_pizza_boxes = held_obj.get_child_count() + 1
			var diff:int = 0
			if num_pizza_boxes > MAX_STACK_SIZE:
				diff = MAX_STACK_SIZE - num_pizza_boxes
				num_pizza_boxes = MAX_STACK_SIZE
			var new_stack = load("uid://dp8cybb476vqi").instantiate() as PizzaBoxStack
			new_stack.num_pizza_boxes = num_pizza_boxes
			new_stack.global_transform = global_transform
			get_parent().add_child(new_stack)
			if diff > 0:
				for i in range(held_obj.get_child_count() - diff):
					held_obj.remove_child(held_obj.get_child(i))
			else:
				held_obj.queue_free()
			queue_free()
			return
		if held_obj.has_meta("name"):
			var mesh_name:String = held_obj.get_meta("name")
			if mesh_name == "pizza_box_open_mesh":
				var new_stack = load("uid://dp8cybb476vqi").instantiate() as PizzaBoxStack
				new_stack.num_pizza_boxes = 2
				new_stack.global_transform = global_transform
				get_parent().add_child(new_stack)
				held_obj.queue_free()
				queue_free()
				return
			if GlobalVar.get_pizza_type_from_name(mesh_name) == GlobalVar.PIZZA_TYPE.PEPPERONI_PIE or \
			GlobalVar.get_pizza_type_from_name(mesh_name) == GlobalVar.PIZZA_TYPE.CHEESE_PIE or \
			GlobalVar.get_pizza_type_from_name(mesh_name) == GlobalVar.PIZZA_TYPE.MUSHROOM_PIE:
				var is_added:bool = add_pizza_to_box(mesh_name)
				if is_added:
					held_obj.queue_free()
				return
		player.drop_item()
	if get_parent():
		get_parent().remove_child(self)
	lid.rotation = Vector3.ZERO
	pickup(Vector3(0.0,-0.5,0.75), Vector3(deg_to_rad(0), deg_to_rad(180), deg_to_rad(0)), player)
	if pizza_slot.has_meta("pizza"):
		player.item_slot.get_child(0).set_meta("pizza", pizza_slot.get_meta("pizza"))
		player.item_slot.get_child(0).set_meta("food_id", pizza_slot.get_meta("food_id"))
	queue_free()

func cook() -> void:
	if not is_cook:
		is_cook = true


func _on_pizza_detection_area_body_entered(body: Node3D) -> void:
	var parent = body.get_parent()
	#if body.has_meta("name") and body.get_meta("name") == "whole_pizza" and is_open:
		#var item = parent as Item
		#if item:
			#if pizza_slot.get_child_count() == 0:
				#var pizza_collider = body.get_node("CollisionShape3D") as CollisionShape3D
				#if pizza_collider:
					#pizza_collider.set_deferred("disabled", true)
				#var _mesh = item.mesh.duplicate()
				#_mesh.position = Vector3.ZERO
				#_mesh.rotation = Vector3.ZERO
				#_mesh.scale = Vector3(0.8,0.8,0.8)
				#if _mesh.has_meta("name"):
					#if _mesh.get_meta("name") == "food_ingredient_pepperoni_pizza_mesh":
						#pizza_slot.set_meta("pizza", GlobalVar.PIZZA_TYPE.PEPPERONI)
						#mesh.set_meta("pizza", GlobalVar.PIZZA_TYPE.PEPPERONI)
						#pizza_slot.set_meta("food_id", GlobalVar.PIZZA_TYPE.PEPPERONI_PIE)
					#elif _mesh.get_meta("name") == "food_ingredient_mushroom_pizza_mesh":
						#pizza_slot.set_meta("pizza", GlobalVar.PIZZA_TYPE.MUSHROOM)
						#mesh.set_meta("pizza", GlobalVar.PIZZA_TYPE.MUSHROOM)
						#pizza_slot.set_meta("food_id", GlobalVar.PIZZA_TYPE.MUSHROOM_PIE)
					#elif _mesh.get_meta("name") == "food_ingredient_cheese_pizza_mesh":
						#pizza_slot.set_meta("pizza", GlobalVar.PIZZA_TYPE.CHEESE)
						#mesh.set_meta("pizza", GlobalVar.PIZZA_TYPE.CHEESE)
						#pizza_slot.set_meta("food_id", GlobalVar.PIZZA_TYPE.CHEESE_PIE)
					#else:
						#pizza_slot.set_meta("pizza", GlobalVar.PIZZA_TYPE.NONE)
						#mesh.set_meta("pizza", GlobalVar.PIZZA_TYPE.NONE)
						#pizza_slot.set_meta("food_id", GlobalVar.PIZZA_TYPE.NONE)
				#pizza_slot.add_child(_mesh)
				#item.shrink_and_free(0, 0)
	if parent is PizzaBox and parent != self:
		if has_meta("food_id"):
			return
		if parent.has_meta("food_id"):
			return
		if body is RigidBody3D:
			await get_tree().create_timer(0.5).timeout
			if not is_instance_valid(self) or not is_instance_valid(get_parent()):
				return
			var pizzabox_stack = PIZZABOX_STACK.instantiate() as PizzaBoxStack
			pizzabox_stack.num_pizza_boxes = 2
			get_parent().add_child(pizzabox_stack)
			pizzabox_stack.transform = parent.transform
			get_parent().remove_child(self)
			parent.get_parent().remove_child(parent)
			parent.queue_free()
			queue_free()


func add_pizza_to_box(mesh_name:String) -> bool:
	var item:Item = GlobalVar.get_item_from_mesh(mesh_name)
	if not item:
		return false
	if pizza_slot.get_child_count() > 0:
		return false
	var item_mesh = item.mesh.duplicate()
	item_mesh.position = Vector3.ZERO
	item_mesh.rotation = Vector3.ZERO
	item_mesh.scale = Vector3(0.8,0.8,0.8)
	if item_mesh.has_meta("name"):
		if item_mesh.get_meta("name") == "food_ingredient_pepperoni_pizza_mesh":
			pizza_slot.set_meta("pizza", GlobalVar.PIZZA_TYPE.PEPPERONI)
			mesh.set_meta("pizza", GlobalVar.PIZZA_TYPE.PEPPERONI)
			pizza_slot.set_meta("food_id", GlobalVar.PIZZA_TYPE.PEPPERONI_PIE)
		elif item_mesh.get_meta("name") == "food_ingredient_mushroom_pizza_mesh":
			pizza_slot.set_meta("pizza", GlobalVar.PIZZA_TYPE.MUSHROOM)
			mesh.set_meta("pizza", GlobalVar.PIZZA_TYPE.MUSHROOM)
			pizza_slot.set_meta("food_id", GlobalVar.PIZZA_TYPE.MUSHROOM_PIE)
		elif item_mesh.get_meta("name") == "food_ingredient_cheese_pizza_mesh":
			pizza_slot.set_meta("pizza", GlobalVar.PIZZA_TYPE.CHEESE)
			mesh.set_meta("pizza", GlobalVar.PIZZA_TYPE.CHEESE)
			pizza_slot.set_meta("food_id", GlobalVar.PIZZA_TYPE.CHEESE_PIE)
		else:
			pizza_slot.set_meta("pizza", GlobalVar.PIZZA_TYPE.NONE)
			mesh.set_meta("pizza", GlobalVar.PIZZA_TYPE.NONE)
			pizza_slot.set_meta("food_id", GlobalVar.PIZZA_TYPE.NONE)
	pizza_slot.add_child(item_mesh)
	item.queue_free()
	return true
