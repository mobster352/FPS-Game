extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignal.spawn_new_level.connect(_spawn_new_level)


func _spawn_new_level() -> void:
	await get_tree().create_timer(0.001).timeout
	var level_node:Node3D = load("res://environment/level_1.tscn").instantiate()
	if level_node:
		level_node.name = "Level"
		add_child(level_node)
		var foreground:ColorRect = get_node("/root/Node/CanvasLayer/Foreground")
		var tween = create_tween()
		tween.tween_property(foreground, "color:a", 0.0, 0.5)
		#await tween.finished
	else:
		print("Something went wrong changing the scene: ", level_node)
