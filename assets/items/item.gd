extends Node3D
class_name Item

@export var mesh: MeshInstance3D
@export var rigid_body: RigidBody3D
@export var area: Area3D
@export var meshInstanceArray: Array[MeshInstance3D]
var standardMaterial3D: StandardMaterial3D
@export var albedo_texture: Texture2D
@export var disposable: bool
@export var pointer: Node3D

var player: Player
var disabled := false
var kill := false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	standardMaterial3D = StandardMaterial3D.new()
	standardMaterial3D.albedo_texture = albedo_texture
	for m in meshInstanceArray:
		m.set_surface_override_material(0,standardMaterial3D)
	GlobalSignal.toggle_pointer_by_food.connect(_toggle_pointer_by_food)

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
				
func set_z_scale_children(value: bool, new_mesh: Node3D) -> void:
	for m in new_mesh.get_children():
		if m.get_child(0) is MeshInstance3D:
			var m_child = m.get_child(0) as MeshInstance3D
			m_child.set_surface_override_material(0, StandardMaterial3D.new())
			var material = m_child.get_surface_override_material(0)
			if material is BaseMaterial3D:
				material.use_z_clip_scale = value
				if value and material.z_clip_scale == 1.0:
					material.z_clip_scale = 0.1


func pickup(new_pos: Vector3, new_rotation: Vector3) -> void:
	var new_mesh = mesh.duplicate()
	new_mesh.position = new_pos
	new_mesh.rotation = new_rotation
	
	if has_meta("count"):
		new_mesh.set_meta("count", get_meta("count"))
		set_z_scale_children(true, new_mesh)
	
	player.item_slot.add_child(new_mesh)

	set_monitoring(false)
	set_z_scale(true)
	
	if has_meta("food_id"):
		GlobalSignal.pickup_food.emit(get_meta("food_id"))
		pointer.hide()
	elif has_meta("plate_dirty"):
		pointer.hide()
		GlobalSignal.toggle_pointer.emit("sink", true)


func shrink_and_free(money:int) -> void:
	if pointer:
		pointer.hide()
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(rigid_body, "scale", Vector3(0.001,0.001,0.001), 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(rigid_body, "position:y", position.y - 5.0, 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	if money:
		tween.tween_callback(_pay_player.bind(money))
	tween.tween_callback(queue_free).set_delay(5.0)

func _pay_player(money:int) -> void:
	player.update_money(money)

func _toggle_pointer_by_food(food_id:int, value:bool) -> void:
	if has_meta("food_id"):
		if get_meta("food_id") == food_id:
			pointer.visible = value
