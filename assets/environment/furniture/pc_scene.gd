extends StaticBody3D
class_name PCStatic

var player:Player
var is_using:bool = false
@onready var camera_3d: Camera3D = %Camera3D
@onready var sub_viewport: SubViewport = $SubViewport
@onready var pc_control: Control = $SubViewport/PCControl

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func toggle_use() -> void:
	is_using = !is_using
	camera_3d.current = is_using

func _input(event: InputEvent) -> void:
	if !is_using:
		return
	if not player.freeze_camera:
		player._freeze_player_camera(true)
	if event is InputEventKey:
		if Input.is_action_just_pressed("exit_pc"):
			toggle_use()
			player._freeze_player_camera(false)
			player.camera.current = true
			player.reticle.show()
		else:
			sub_viewport.push_input(event)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_MIDDLE:
			var mouse_event = InputEventMouseButton.new()
			mouse_event.button_index = event.button_index
			mouse_event.pressed = event.pressed
			mouse_event.position = pc_control.pc_mouse_pos
			mouse_event.global_position = pc_control.pc_mouse_pos
			sub_viewport.push_input(mouse_event)
	elif event is InputEventMouseMotion:
		pc_control.pc_mouse_pos += event.relative
		pc_control.pc_mouse_pos.x = clamp(pc_control.pc_mouse_pos.x, 0.0, sub_viewport.size.x - 10.0)
		pc_control.pc_mouse_pos.y = clamp(pc_control.pc_mouse_pos.y, 0.0, sub_viewport.size.x - 10.0)
		pc_control.update_cursor_pos()
