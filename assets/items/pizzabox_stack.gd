extends Node3D
class_name PizzaBoxStack

@export var num_pizza_boxes:int = 0

@onready var pizzabox = preload("uid://cpulw2n2h8hsx")
@onready var pizzabox_open = load("uid://bxflb6heaetxd")
@export var pizza_boxes: Node3D
@onready var this_body
@onready var preview_scene = load("uid://7t2skrh4o8jq")

const BOX_SPACING = 0.3
var in_range := false
var disabled := false

func _ready() -> void:
	if has_node("body"):
		this_body = $body
	for i in range(num_pizza_boxes):
		add_box_at_index(i)

func get_pos(index:int) -> float:
	return index * BOX_SPACING

func add_box_at_index(index:int) -> void:
	var box = pizzabox.instantiate() as Node3D
	box.position = Vector3(0.0,get_pos(index),0.0)
	box.rotation = Vector3.ZERO
	pizza_boxes.add_child(box)

func remove_box_from_stack() -> PizzaBox:
	var existing_box = pizza_boxes.get_child(-1)
	pizza_boxes.remove_child(existing_box)
	existing_box.queue_free()
	
	num_pizza_boxes -= 1
	var new_pizzabox = pizzabox_open.instantiate() as PizzaBox
	return new_pizzabox


func _on_stack_area_body_entered(body: Node3D) -> void:
	var parent = body.get_parent()
	if parent is PizzaBox:
		if num_pizza_boxes == 10:
			var rigidbody = body as RigidBody3D
			if rigidbody:
				var forward = -rigidbody.global_transform.basis.z.normalized()
				var throw_strength: float = 2.0
				body.apply_impulse(forward * (throw_strength / rigidbody.mass), rigidbody.global_position + forward)
			return
		add_box_at_index(num_pizza_boxes)
		num_pizza_boxes += 1
		parent.shrink_and_free(0, 0)

func interact(player: Player) -> void:
	if player.has_held_object():
		player.drop_item()
	var new_pizzabox = remove_box_from_stack()
	pizza_boxes.add_child(new_pizzabox)
	if new_pizzabox:
		new_pizzabox.pickup(Vector3(0.0,-0.5,0.75), Vector3(deg_to_rad(0), deg_to_rad(180), deg_to_rad(0)))
		new_pizzabox.queue_free()
	if num_pizza_boxes == 0:
		queue_free()
		
func interact2(player: Player) -> void:
	if player.has_held_object():
		if disabled:
			return
		player.drop_item()
		return
	else:
		pickup(Vector3.ZERO, Vector3.ZERO, player)


func _on_detection_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true


func _on_detection_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false

func pickup(_new_pos: Vector3, _new_rotation: Vector3, player: Player) -> void:
	if player.has_held_object():
		player.drop_item()
	else:
		this_body.remove_child(pizza_boxes)
		player.item_slot.add_child(pizza_boxes)
		pizza_boxes.position = Vector3(0.0,-1.0,1.0)
		set_z_scale_children(true, pizza_boxes)
		player.setup_placement_pizzabox_stack(preview_scene, "uid://dp8cybb476vqi", num_pizza_boxes)
		queue_free()

func set_z_scale_children(value: bool, node: Node3D) -> void:
	for m in node.get_children():
		if m.get_child_count() > 0:
			if m.get_child(0) is MeshInstance3D:
				var m_child = m.get_child(0) as MeshInstance3D
				m_child.set_surface_override_material(0, StandardMaterial3D.new())
				var material = m_child.get_surface_override_material(0)
				material.albedo_texture = load("uid://cruxwxefv2v1j") as Texture2D
				if material is BaseMaterial3D:
					material.use_z_clip_scale = value
					if value and material.z_clip_scale == 1.0:
						material.z_clip_scale = 0.1
		for c in m.get_children():
			if c.get_child_count() > 0:
				if c.get_child(0) is MeshInstance3D:
					var m_child = c.get_child(0) as MeshInstance3D
					m_child.set_surface_override_material(0, StandardMaterial3D.new())
					var material = m_child.get_surface_override_material(0)
					material.albedo_texture = load("uid://cruxwxefv2v1j") as Texture2D
					if material is BaseMaterial3D:
						material.use_z_clip_scale = value
						if value and material.z_clip_scale == 1.0:
							material.z_clip_scale = 0.1
