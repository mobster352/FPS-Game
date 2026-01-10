extends Node3D
class_name Item

@export var area: Area3D
@export var meshInstanceArray: Array[MeshInstance3D]
var standardMaterial3D: StandardMaterial3D
@export var albedo_texture: Texture2D
@export var disposable: bool

@onready var player: Player
var disabled := false
var kill := false

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


func shrink_and_free(money:int) -> void:
	var body = get_child(0)
	if body is RigidBody3D:
		body.freeze = true
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(0.001,0.001,0.001), 0.25).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "position:y", 0, 0.5).set_trans(Tween.TRANS_LINEAR)
	if money:
		tween.tween_callback(_pay_player.bind(money))
	tween.tween_callback(queue_free).set_delay(2.0)

func _pay_player(money:int) -> void:
	player.update_money(money)
