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

# Internal state
var time_of_day := 0.0 # 0–24

const SUNRISE := 6.0
const SUNSET  := 18.0
const MAX_ELEVATION := PI / 2.0  # 90°

func _ready():
	time_of_day = start_time
	update_environment()
	update_sun()
	update_sun_light()

func _process(delta):
	advance_time(delta)
	update_sun()
	update_sun_light()
	update_environment()
	#print("Time:", time_of_day, " SunFactor:", get_sun_factor())

func advance_time(delta: float):
	var seconds_per_day = day_length_minutes * 60.0
	var hours_per_second = 24.0 / seconds_per_day

	time_of_day += delta * hours_per_second
	time_of_day = fmod(time_of_day, 24.0)

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
	env.ambient_light_energy = lerp(0.05, 1.0, f)
	env.background_energy_multiplier = lerp(0.2, 1.0, f)

func get_sun_factor() -> float:
	# Based on sun angle, not time
	var sun_dir := sun.global_transform.basis.z
	var height := sun_dir.y

	# Fade between -0.1 and +0.2 (below → above horizon)
	return smoothstep(-0.4, 0.2, height)


func update_sun_light():
	var f := get_sun_factor()
	sun.light_energy = lerp(sun_min_energy, sun_max_energy, f)
	sun.shadow_enabled = f > 0.15
