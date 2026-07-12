extends Node3D

@export var lane_path_01: Path3D
@export var lane_path_02: Path3D
@export var drive_thru_path: Path3D
@export var return_path: Path3D
@export var level:Level
@onready var drive_thru_enter_area: Area3D = %DriveThruEnterArea

@onready var car_spawner: CarSpawner = %CarSpawner

const CAR_SCENE:PackedScene = preload("uid://ba1j54egm4o")

var is_store_open:bool = false
var car_paths:Dictionary[TrafficCar, Path3D]
var number_cars_in_drive_thru:int = 0:
	set(value):
		number_cars_in_drive_thru = value
		#print(number_cars_in_drive_thru)

func _ready() -> void:
	GlobalSignal.open_store.connect(_open_store)
	GlobalSignal.leave_drive_thru.connect(_leave_drive_thru)
	
	var initial_progress_ratio_array:Array[float] = [0.1, 0.4, 0.8]
	for i:int in range(3):
		spawn_car(lane_path_01, initial_progress_ratio_array[i])
		spawn_car(lane_path_02, initial_progress_ratio_array[i])


func spawn_car(lane:Path3D, initial_progress_ratio:float) -> void:
	var random_progress_ratio:float = initial_progress_ratio
	var traffic_car:TrafficCar
	traffic_car = car_spawner.spawn_car_on_lane(lane, CAR_SCENE, random_progress_ratio)
	traffic_car.return_to_original_path.connect(_return_to_original_path)
	car_paths.set(traffic_car, lane)


func _on_drive_thru_enter_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("traffic"):
		drive_thru_enter_area.set_deferred("monitoring", false)
		var traffic_car:TrafficCar = body.get_parent()
		if traffic_car.is_area_disabled:
			return
		traffic_car.is_area_disabled = true
		var drive_thru_chance = randi_range(0, 9)
		#var drive_thru_chance = 0
		if level.time_of_day < 22 and drive_thru_chance == 0 and is_store_open and number_cars_in_drive_thru < 3:
			traffic_car.path_follow.reparent(drive_thru_path)
			traffic_car.path_follow.progress_ratio = 0
			traffic_car.is_path_drive_thru = true
			traffic_car.path_follow.loop = false
			number_cars_in_drive_thru += 1
		await get_tree().create_timer(3.0).timeout
		drive_thru_enter_area.set_deferred("monitoring", true)


func _open_store() -> void:
	is_store_open = true


func _leave_drive_thru(traffic_car:TrafficCar) -> void:
	traffic_car.path_follow.reparent(return_path)
	traffic_car.path_follow.progress_ratio = 0
	traffic_car.is_path_return = true
	traffic_car.path_follow.loop = false
	number_cars_in_drive_thru -= 1


func _return_to_original_path(traffic_car:TrafficCar) -> void:
	var original_path:Path3D = car_paths.get(traffic_car)
	traffic_car.path_follow.reparent(original_path)
	traffic_car.path_follow.progress_ratio = 0.23
	traffic_car.path_follow.loop = true
