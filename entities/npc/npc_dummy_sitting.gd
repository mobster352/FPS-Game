extends Node3D

@export var area: Area3D

var table_id: int
var in_range := false
var has_order := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	table_id = get_parent().get_parent().get_meta("table_id") as int


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if in_range and not has_order:
		if Input.is_action_just_pressed("interact"):
			var random_food = randi_range(0,2)
			GlobalSignal.add_order.emit(table_id, random_food)
			has_order = true

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false
