extends Node3D
class_name Item

@export var area: Area3D
@export var meshInstanceArray: Array[MeshInstance3D]
var standardMaterial3D: StandardMaterial3D
@export var albedo_texture: Texture2D

@onready var player: Player
var disabled := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	standardMaterial3D = StandardMaterial3D.new()
	standardMaterial3D.albedo_texture = albedo_texture
	for m in meshInstanceArray:
		m.set_surface_override_material(0,standardMaterial3D)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player.append_item_in_range(self)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player.remove_item_in_range(self)


func set_monitoring(value: bool) -> void:
	area.monitoring = value


func set_z_scale(value: bool) -> void:
	for m in meshInstanceArray:
		var material = m.get_surface_override_material(0)
		if material is BaseMaterial3D:
			material.use_z_clip_scale = value
			if value and material.z_clip_scale == 1.0:
				material.z_clip_scale = 0.1


func pickup(new_rotation: Vector3) -> void:
	position = Vector3.ZERO
	rotation = new_rotation

	var body = get_child(0)
	if body is RigidBody3D:
		body.freeze = true
		body.position = Vector3.ZERO
		body.rotation = Vector3.ZERO
		var shape = body.get_child(0)
		if shape is CollisionShape3D:
			shape.disabled = true

	set_monitoring(false)
	set_z_scale(true)
