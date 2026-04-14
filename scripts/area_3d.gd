extends Area3D

@export var subViewport:SubViewport
@export var computer:Computer

func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouse or event is InputEventScreenDrag or event is InputEventScreenTouch:
		#return
	if computer.use:
		subViewport.push_input(event)

func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	#%SubViewport.handle_input_locally = true
	
	subViewport.push_input(event)
	
	#%SubViewport.handle_input_locally = false
