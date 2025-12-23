extends CharacterBody3D

var health := 3

func take_damage(damage:int) -> void:
	health -= damage
	if health <= 0:
		queue_free()
