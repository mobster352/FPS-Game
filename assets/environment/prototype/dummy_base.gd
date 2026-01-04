extends Node3D

@export var head_hitbox: CollisionShape3D
@export var body_hitbox: CollisionShape3D
@export var arm_left_hitbox: CollisionShape3D
@export var arm_right_hitbox: CollisionShape3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func take_damage(damage:int, target:CollisionShape3D) -> void:
	if target == head_hitbox:
		print("Head was hit for ", damage+1, " damage")
	elif target == body_hitbox:
		print("Body was hit for ", damage, " damage")
	elif target == arm_left_hitbox:
		print("Left Arm was hit for ", damage, " damage")
	elif target == arm_right_hitbox:
		print("Right Arm was hit for ", damage, " damage")
