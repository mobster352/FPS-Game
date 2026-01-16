extends Item
class_name PizzaBox

@export var lid: MeshInstance3D
@export var speed := 1.5
@export var pizza_slot: Node3D

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

func interact() -> void:
	if disabled:
		return
	if player.item_slot.get_child_count() > 0:
		player.drop_item()
	if get_parent():
		get_parent().remove_child(self)
	pickup(Vector3.ZERO, Vector3.ZERO)
	if pizza_slot.has_meta("pizza"):
		player.item_slot.get_child(0).set_meta("pizza", pizza_slot.get_meta("pizza"))
	queue_free()

func cook() -> void:
	if not is_cook:
		is_cook = true


func _on_pizza_detection_area_body_entered(body: Node3D) -> void:
	if body.has_meta("name") and body.get_meta("name") == "whole_pizza" and is_open:
		var item = body.get_parent() as Item
		if item:
			if pizza_slot.get_child_count() == 0:
				var _mesh = item.get_node("body/mesh")
				_mesh.position = Vector3.ZERO
				_mesh.rotation = Vector3.ZERO
				if _mesh.get_parent():
					_mesh.get_parent().remove_child(_mesh)
				if item.mesh.has_meta("name"):
					if item.mesh.get_meta("name") == "food_ingredient_pepperoni_pizza_mesh":
						pizza_slot.set_meta("pizza", GlobalVar.PIZZA_TYPE.PEPPERONI)
					elif item.mesh.get_meta("name") == "food_ingredient_mushroom_pizza_mesh":
						pizza_slot.set_meta("pizza", GlobalVar.PIZZA_TYPE.MUSHROOM)
					elif item.mesh.get_meta("name") == "food_ingredient_cheese_pizza_mesh":
						pizza_slot.set_meta("pizza", GlobalVar.PIZZA_TYPE.CHEESE)
					else:
						pizza_slot.set_meta("pizza", GlobalVar.PIZZA_TYPE.NONE)
				pizza_slot.add_child(_mesh)
				mesh_has_children = true
			item.shrink_and_free(0, 0.25)
