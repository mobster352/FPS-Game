extends Item
class_name PizzaBox

@export var lid: MeshInstance3D
@export var speed := 1.5

var is_open := false
var is_cook := false
var is_interact := false
var elapsed := 0.0

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
	if not is_interact:
		is_interact = true

func cook() -> void:
	if not is_cook:
		is_cook = true
