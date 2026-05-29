class_name Car
extends Node3D

const ROTATION_DEGREES = 1
const END_PATH_DISTANCE = 0.001

@export var ROTATION_SPEED = 300.0

@export var target_speed:float = 10.0

@export var car_path:PathFollow3D
@export var drive_thru_path:PathFollow3D
@export var return_car_path:PathFollow3D
@export var level:Level

var current_path:PathFollow3D
var is_moving:bool = false
var is_store_open:bool = false

var audio_played:bool = false


func _ready() -> void:
	GlobalSignal.open_store.connect(_open_store)
	current_path = car_path

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_wheels(delta)

func _physics_process(delta: float) -> void:
	if current_path == car_path:
		if 1.0 - current_path.progress_ratio <= END_PATH_DISTANCE:
			is_moving = false
			var drive_thru_chance = randi_range(0, 3)
			#var drive_thru_chance = 0
			if level.time_of_day < 22 and drive_thru_chance == 0 and is_store_open:
				current_path = drive_thru_path
				car_path.remove_child(get_parent())
				drive_thru_path.add_child(get_parent())
			current_path.progress_ratio = 0
			return
		if not is_moving:
			is_moving = true
		current_path.progress += target_speed * delta
	elif current_path == drive_thru_path:
		if 1.0 - current_path.progress_ratio <= END_PATH_DISTANCE:
			is_moving = false
			if not audio_played:
				%Honk.play()
				audio_played = true
			return
		if not is_moving:
			is_moving = true
		current_path.progress += target_speed * delta
	elif current_path == return_car_path:
		if 1.0 - current_path.progress_ratio <= END_PATH_DISTANCE:
			is_moving = false
			current_path = car_path
			return_car_path.remove_child(get_parent())
			car_path.add_child(get_parent())
			current_path.progress_ratio = 0.155
			audio_played = false
			return
		if not is_moving:
			is_moving = true
		current_path.progress += target_speed * delta

func rotate_wheels(delta:float) -> void:
	if is_moving:
		%car_taxi_wheel_front_left.rotation.x += deg_to_rad(ROTATION_DEGREES) * ROTATION_SPEED * delta
		%car_taxi_wheel_front_right.rotation.x += deg_to_rad(ROTATION_DEGREES) * ROTATION_SPEED * delta
		%car_taxi_wheel_rear_left.rotation.x += deg_to_rad(ROTATION_DEGREES) * ROTATION_SPEED * delta
		%car_taxi_wheel_rear_right.rotation.x += deg_to_rad(ROTATION_DEGREES) * ROTATION_SPEED * delta


func leave_drive_thru() -> void:
	current_path = return_car_path
	drive_thru_path.remove_child(get_parent())
	return_car_path.add_child(get_parent())
	current_path.progress_ratio = 0


func _open_store() -> void:
	is_store_open = true
