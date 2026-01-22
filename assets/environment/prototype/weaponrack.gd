extends Node3D
class_name WeaponRack

@export var pistol: Node3D
@export var bat: Node3D

var in_range := false

enum WeaponType {
	None,
	Bat,
	Pistol
}


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false


func interact(player: Player, weapon_type: WeaponType) -> void:
	if weapon_type == WeaponType.Bat:
		bat.queue_free()
		player.has_bat = true
	elif weapon_type == WeaponType.Pistol:
		pistol.queue_free()
		player.has_pistol = true
