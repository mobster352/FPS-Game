extends Control

@export var time: Label
@export var level: Level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var rounded_float = snappedf(level.time_of_day, 0.01)
	var decimal = rounded_float - int(rounded_float)
	var minutes = decimal * 100 * 0.6
	if int(round(minutes)) < 10:
		time.text = str(int(rounded_float), ":0", int(round(minutes)))
	else:
		time.text = str(int(rounded_float), ":", int(round(minutes)))
	
