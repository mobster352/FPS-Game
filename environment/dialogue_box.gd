extends Node3D
class_name DialogueBox

@export var dialogue_id: StringName
var current_index:int = 0

@onready var canvas_layer: CanvasLayer = %CanvasLayer
@onready var label = %Label
@onready var display_timer = $Timers/DisplayTimer


func _ready() -> void:
	set_process(false)

func _process(_delta: float) -> void:
	if not visible:
		return
	if Input.is_action_just_pressed("interact"):
		hide()


func _on_visibility_changed() -> void:
	if visible:
		label.text = ResourceManager.get_dialogue_by_id(dialogue_id, current_index)
		canvas_layer.show()
		GlobalSignal.freeze_player_camera.emit(true)
		set_process(true)
	else:
		canvas_layer.hide()
		GlobalSignal.freeze_player_camera.emit(false)
		set_process(false)


func _on_display_timer_timeout() -> void:
	hide()
	canvas_layer.hide()

func get_order_text() -> StringName:
	return "I want a "

func get_good_order_delivered_text() -> StringName:
	return "PIZZAAAA"
	
func get_bad_order_delivered_text() -> StringName:
	return "I didn't order that"
