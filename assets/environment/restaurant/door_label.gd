extends Label3D

@export var door: Door

func _ready() -> void:
	text = "$" + str(door.money_required)
	hide()
