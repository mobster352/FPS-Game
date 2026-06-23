class_name Package
extends Item

@export var room_number:int:
	set(value):
		room_number = value
		if room_label:
			room_label.text = str(room_number)
@export var starting_pos:Transform3D
@onready var room_label: Label3D = %RoomLabel
@onready var timer: Timer = $Timers/Timer
var is_disabled:bool = false

func _ready() -> void:
	super()
	room_label.text = str(room_number)

func pickup(new_pos: Vector3, new_rotation: Vector3, _player) -> void:
	super(new_pos, new_rotation, _player)
	room_label.no_depth_test = true
	if player.get_held_object_mesh_name() == "package_mesh":
		player.get_held_object().set_meta("starting_pos", starting_pos)

func _on_timer_timeout() -> void:
	hide()
	get_child(0).global_transform = starting_pos
	show()
