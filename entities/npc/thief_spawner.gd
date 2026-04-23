class_name ThiefSpawner
extends Marker3D

@export var game_state:GameState
@export var endPathMarker:Marker3D

func _ready() -> void:
	GlobalSignal.open_store.connect(_open_store)
	GlobalSignal.close_store.connect(_close_store)
	
func _open_store() -> void:
	%ThiefTimer.start()
	
	
func _close_store() -> void:
	%ThiefTimer.stop()
	

func _on_thief_timer_timeout() -> void:
	var thief:Thief = preload("uid://cgoev8wqbi1ks").instantiate()
	thief.game_state = game_state
	thief.end_path_marker = endPathMarker
	thief.position = position + Vector3(0, 0, randf_range(-0.5,0.5))
	thief.rotation = rotation
	%ThiefTimer.wait_time = randf_range(15, 30)
	get_parent().add_child(thief)
