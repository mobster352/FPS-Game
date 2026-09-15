class_name LandlinePhone
extends StaticBody3D

var is_ringing:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_ringing(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func set_ringing(value:bool) -> void:
	if value:
		is_ringing = true
		%RingAudio.play()
	else:
		is_ringing = false
		%RingAudio.stop()
