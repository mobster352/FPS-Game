extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignal.spawn_new_level.connect(_spawn_new_level)


func _spawn_new_level() -> void:
	await get_tree().create_timer(0.1).timeout
	var level_node:Node3D = load("res://environment/level_1.tscn").instantiate()
	if level_node:
		level_node.name = "Level"
		add_child(level_node)
	else:
		print("Something went wrong changing the scene: ", level_node)
