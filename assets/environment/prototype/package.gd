class_name Package
extends Item

@export var room_number:int:
	set(value):
		room_number = value
		if room_label:
			room_label.text = str(room_number)
@onready var room_label: Label3D = %RoomLabel
var is_disabled:bool = false

func _ready() -> void:
	super()
	room_label.text = str(room_number)
