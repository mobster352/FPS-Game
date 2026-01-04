extends Node3D
class_name Door

@export var speed := 1.5
@export var is_locked := false
@export var number_required := 1

var in_range := false
var is_open := false
var interact_door := false
var elapsed := 0.0
var count := 0


func _process(delta: float) -> void:
	if elapsed >= 1.0:
		interact_door = false
		is_open = not is_open
		elapsed = 0.0
	if interact_door:
		if is_open:
			basis = lerp(basis,basis.rotated(Vector3.UP, deg_to_rad(-90)).orthonormalized(), speed * delta)
		else:
			basis = lerp(basis,basis.rotated(Vector3.UP, deg_to_rad(90)).orthonormalized(), speed * delta)
		elapsed += speed * delta


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false


func door_interact() -> void:
	if in_range and not interact_door and not is_locked:
		interact_door = true


func close_door() -> void:
	if is_open:
		interact_door = true
