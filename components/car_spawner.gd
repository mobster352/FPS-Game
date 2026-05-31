class_name CarSpawner
extends Node3D

func spawn_car_on_lane(lane: Path3D, car_scene: PackedScene, random_progress_ratio:float) -> TrafficCar:
	var follow := PathFollow3D.new()
	follow.use_model_front = true
	follow.rotation_mode = PathFollow3D.ROTATION_ORIENTED
	lane.add_child(follow)
	follow.progress_ratio = random_progress_ratio

	var car:TrafficCar = car_scene.instantiate()
	follow.add_child(car)
	car.setup(follow)
	return car
