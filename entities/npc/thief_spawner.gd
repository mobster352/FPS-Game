class_name ThiefSpawner
extends Marker3D

@export var game_state:GameState
@export var endPathMarker:Marker3D
@onready var thief_timer: Timer = %ThiefTimer

func _ready() -> void:
	GlobalSignal.open_store.connect(_open_store)
	GlobalSignal.close_store.connect(_close_store)
	
func _process(_delta: float) -> void:
	if game_state.level.time_of_day > 18 and thief_timer.is_stopped():
		thief_timer.start()
	elif game_state.level.time_of_day >= 21 and not thief_timer.is_stopped():
		thief_timer.stop()
		set_physics_process(false)
	
func _open_store() -> void:
	#if game_state.level.time_of_day > 19 and thief_timer.is_stopped():
		#thief_timer.start()
	pass
	
	
func _close_store() -> void:
	#%ThiefTimer.stop()
	pass
	

func _on_thief_timer_timeout() -> void:
	var thief:Thief = preload("uid://cgoev8wqbi1ks").instantiate()
	thief.game_state = game_state
	thief.end_path_marker = endPathMarker
	thief.position = position + Vector3(0, 0, randf_range(-0.5,0.5))
	thief.rotation = rotation
	thief_timer.wait_time = randf_range(30, 60)
	get_parent().add_child(thief)
