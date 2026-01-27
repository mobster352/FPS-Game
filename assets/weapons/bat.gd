extends Weapon
class_name Bat

@export var animation_player: AnimationPlayer
@export var collider: CollisionShape3D

func _ready() -> void:
	has_ammo = false

func shoot_animation() -> void:
	animation_player.play("Swing")


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies"):
		call_deferred("update_collider", true)
		if body.has_method("take_damage"):
			body.call_deferred("take_damage", 1)
	elif body.is_in_group("thief"):
			if body.has_method("hit"):
				body.call_deferred("hit")

func update_collider(value: bool) -> void:
	collider.disabled = value
