extends Node3D
class_name Level

@export var sun_pivot: Node3D
@export var sun: DirectionalLight3D
@export var world_environment: WorldEnvironment

# Time settings
@export_range(0.0, 24.0) var start_time := 6.0 # 6 AM
@export var day_length_minutes := 60.0 # real minutes for a full 24h cycle
@export var sun_max_energy := 1.0
@export var sun_min_energy := 0.0
@export var level_ui: Level_UI
@export var restaurant: Restaurant
@export var player: Player
@export var can_advance_time := true
@export var show_clock := true

# Internal state
var time_of_day := 0.0 # 0–24

var quest_log:QuestLog

const SUNRISE := 6.0
const SUNSET  := 18.0
const MAX_ELEVATION := PI / 2.0  # 90°
#var sky_shader:ShaderMaterial
var sky:ProceduralSkyMaterial

func _ready():
	time_of_day = start_time
	update_environment()
	update_sun()
	update_sun_light()
	if restaurant:
		GlobalSignal.init_restaurant.emit(restaurant)
	if player:
		GlobalSignal.init_player.emit(player)
	GlobalMarker._ready()
	level_ui.show_clock = show_clock
	quest_log = get_tree().get_first_node_in_group("quest_log")
	#sky_shader = world_environment.environment.sky.sky_material
	#sky_shader.set_shader_parameter("stars_intensity", 0.0)
	sky = world_environment.environment.sky.sky_material
	
	GlobalMarker.update_markers.emit()

func _process(delta):
	if can_advance_time and time_of_day < 22:
		advance_time(delta)
	update_sun()
	update_sun_light()
	update_environment()
		#print("Time:", time_of_day, " SunFactor:", get_sun_factor())
	if time_of_day >= 22:
		if is_instance_valid(quest_log):
			quest_log.update_quest_objective(QuestIds.SERVE_CUSTOMERS, QuestObjs.SERVE_CUSTOMERS)

func advance_time(delta: float):
	var seconds_per_day = day_length_minutes * 60.0
	var hours_per_second = 24.0 / seconds_per_day

	time_of_day += delta * hours_per_second
	time_of_day = fmod(time_of_day, 24.0)
	
	if time_of_day > 22:
		GlobalSignal.close_store.emit()

func update_sun():
	# Shift time so sunrise happens at 6.0
	var shifted_time := time_of_day - 12

	# Normalize to 0–1
	var day_t := shifted_time / 24.0

	# Wrap properly
	day_t = fposmod(day_t, 1.0)

	# Full arc: below → above → below
	var angle := day_t * TAU - PI / 2.0

	sun_pivot.rotation.x = angle


func update_environment():
	var f := get_sun_factor()

	var env := world_environment.environment
	env.ambient_light_energy = lerp(0.15, 0.35, f)
	env.background_energy_multiplier = lerp(0.5, 0.75, f)
	
	#if not sky_shader:
		#return
	#set_night_shader_params(f)
	
	if not sky:
		return
	set_night_sky(f)

func get_sun_factor() -> float:
	# Based on sun angle, not time
	var sun_dir := sun.global_transform.basis.z
	var height := sun_dir.y

	# Fade between -0.1 and +0.2 (below → above horizon)
	return smoothstep(-0.1, 0.2, height)


func update_sun_light():
	var f := get_sun_factor()
	sun.light_energy = lerp(sun_min_energy, sun_max_energy, f)
	sun.shadow_enabled = f > 0.15


#func set_day_shader_params() -> void:	
	#sun.light_color = Color("#e0e0e0")
	#
#func set_night_shader_params(f:float) -> void:
	##Sky
	#sky_shader.set_shader_parameter("top_color", Color("#071a40").lerp(Color("#5996ff"), f))
	#sky_shader.set_shader_parameter("bottom_color", Color("#071a40").lerp(Color("#0054f7"), f))
	#sky_shader.set_shader_parameter("sun_scatter", Color("#20165f").lerp(Color("#404040"), f))
	#
	##Clouds
	#sky_shader.set_shader_parameter("clouds_light_color", Color("#3a72ff").lerp(Color("#ffffff"), f))
	#sky_shader.set_shader_parameter("clouds_smoothness", lerp(0.05, 0.03, f))
	#sky_shader.set_shader_parameter("clouds_shadow_intensity", lerp(8.0, 1.0, f))
	#
	##High Clouds
	#sky_shader.set_shader_parameter("high_clouds_density", lerp(0.3, 0.0, f))
	#
	##Stars
	#sky_shader.set_shader_parameter("stars_intensity", lerp(0.5, 0.0, f))
	#
	#sun.light_color = Color("#00053e").lerp(Color("#e0e0e0"), f)


func set_night_sky(f:float) -> void:
	sky.sky_top_color = Color("#071a40").lerp(Color("#5996ff"), f)
	sky.sky_horizon_color = Color("#071a40").lerp(Color("#0054f7"), f)
