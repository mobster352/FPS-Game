extends Node3D
class_name PizzaBoxStack

@export var num_pizza_boxes:int = 0

@onready var pizzabox = preload("uid://cpulw2n2h8hsx")
@onready var pizzabox_open = load("uid://bxflb6heaetxd")

const BOX_SPACING = 0.3
var in_range := false
var disabled := false

func _ready() -> void:
	for i in range(num_pizza_boxes):
		add_box_at_index(i)

func get_pos(index:int) -> float:
	return index * BOX_SPACING

func add_box_at_index(index:int) -> void:
	var box = pizzabox.instantiate() as Node3D
	box.position = Vector3(0.0,get_pos(index),0.0)
	box.rotation = Vector3.ZERO
	add_child(box)

func remove_box_from_stack() -> PizzaBox:
	remove_child(get_child(-1))
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
	add_child(new_pizzabox)
	if new_pizzabox:
		new_pizzabox.pickup(Vector3.ZERO, Vector3(deg_to_rad(0), deg_to_rad(90), deg_to_rad(0)))
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
		pickup(Vector3.ZERO, Vector3.ZERO)


func _on_detection_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true


func _on_detection_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false

func pickup(_new_pos: Vector3, _new_rotation: Vector3) -> void:
	pass
