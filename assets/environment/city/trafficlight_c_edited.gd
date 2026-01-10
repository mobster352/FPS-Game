extends Node3D

@onready var red_light: MeshInstance3D = $trafficlight_C/trafficlight_C_red_light
@onready var yellow_light: MeshInstance3D = $trafficlight_C/trafficlight_C_yellow_light
@onready var green_light: MeshInstance3D = $trafficlight_C/trafficlight_C_green_light
@onready var pedestrian_light: MeshInstance3D = $trafficlight_C/trafficlight_C_pedestrian_light

@onready var timer: Timer = $Timers/Timer

var light:int

enum LIGHT_COLOR {
	RED,
	YELLOW,
	GREEN
}

var pedestrian_light_state := false

func _ready() -> void:
	light = LIGHT_COLOR.RED
	update_emission(red_light, true)

func update_emission(mesh: MeshInstance3D, enabled: bool, emission:Color = Color(0,0,0)) -> void:
	var material = mesh.get_surface_override_material(0)
	if material is BaseMaterial3D:
		material.emission_enabled = enabled
		if emission != Color(0,0,0):
			material.emission = emission

func _on_timer_timeout() -> void:
	if light == LIGHT_COLOR.RED:
		light = LIGHT_COLOR.YELLOW
		update_emission(red_light, false)
		update_emission(yellow_light, true)
	elif light == LIGHT_COLOR.YELLOW:
		light = LIGHT_COLOR.GREEN
		update_emission(yellow_light, false)
		update_emission(green_light, true)
	else:
		light = LIGHT_COLOR.RED
		update_emission(green_light, false)
		update_emission(red_light, true)
	
	pedestrian_light_state = not pedestrian_light_state
	if pedestrian_light_state:
		update_emission(pedestrian_light, true, Color(0,255,0))
	else:
		update_emission(pedestrian_light, true, Color(255,0,0))
		
		
