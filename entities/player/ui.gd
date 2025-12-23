extends Control

@export var ammo_label: RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func update_ammo(ammo_count:int, max_ammo:int) -> void:
	ammo_label.text = str(ammo_count) + " / " + str(max_ammo)
