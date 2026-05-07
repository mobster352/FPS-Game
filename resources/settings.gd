class_name Settings
extends Resource

@export var quality_preset:int
@export var window_mode:int
@export var bg_music_on:bool
@export var rendering_method:String
@export var mouse_sensitivity:float
@export var controller_sensitivity:float
@export var deadzone:float
@export var fov:int

static func update_mouse_sensitivity(value:float) -> float:
	return 0.01 / (10 - value)

static func update_controller_sensitivity(value:float) -> float:
	return value

static func update_deadzone(value:float) -> float:
	return 0.90 / (10 - value)
