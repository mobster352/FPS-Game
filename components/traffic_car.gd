extends Node3D
class_name TrafficCar

signal return_to_original_path(traffic_car:TrafficCar)

@export var speed := 8.0
@export var max_speed := 12.0
@export var acceleration := 4.0
@export var braking := 10.0
@onready var front_check: RayCast3D = %FrontCheck
@onready var honk: AudioStreamPlayer3D = %Honk

const END_PATH_DISTANCE = 0.001

var current_speed := 0.0
var path_follow: PathFollow3D
var is_path_drive_thru:bool = false
var is_path_return:bool = false
var should_stop := false
var is_area_disabled:bool = false:
	set(value):
		is_area_disabled = value
		await get_tree().create_timer(3.0).timeout
		is_area_disabled = false

func setup(follow: PathFollow3D) -> void:
	path_follow = follow

func _physics_process(delta: float) -> void:
	if path_follow == null:
		return

	var blocked := front_check.is_colliding()
	var random_speed:float = randf_range(speed-1, speed+1)
	var target_speed := 0.0 if blocked else random_speed

	if should_stop:
		target_speed = 0.0

	if current_speed < target_speed:
		current_speed = move_toward(current_speed, target_speed, acceleration * delta)
	else:
		current_speed = move_toward(current_speed, target_speed, braking * delta)

	path_follow.progress += current_speed * delta
	global_transform = path_follow.global_transform

	if is_path_drive_thru:
		if 1.0 - path_follow.progress_ratio <= END_PATH_DISTANCE:
			honk.play()
			GlobalSignal.update_drive_thru_menu.emit(true, self)
			is_path_drive_thru = false
			
	if is_path_return:
		if 1.0 - path_follow.progress_ratio <= END_PATH_DISTANCE:
			return_to_original_path.emit(self)
			is_path_return = false
