extends VehicleBody3D

@export var engine_power := 150


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	pass
	#var speed := linear_velocity.length()
	#if speed < target_speed:
		#engine_force = engine_power
		##brake = 0.0
	#else:
		#engine_force = 0
		#brake = 5.0
