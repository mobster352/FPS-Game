extends Area2D

func _input(event):
	if event is InputEventMouse or event is InputEventScreenDrag or event is InputEventScreenTouch:
		return
	%SubViewport.push_input(event)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# This line is a hack, that needs to be removed after https://github.com/godotengine/godot/pull/77926 gets merged
	#$SubViewport.handle_input_locally = true
	
	%SubViewport.push_input(event)

	# This line is a hack, that needs to be removed after https://github.com/godotengine/godot/pull/77926 gets merged
	#$SubViewport.handle_input_locally = false
