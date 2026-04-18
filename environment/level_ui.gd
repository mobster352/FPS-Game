extends Control
class_name Level_UI

@export var level: Level

@export var inputs_ui: InputsUI
@export var next_day_ui: Control

var _player

var show_clock: bool:
	set(value):
		show_clock = value
		if not value:
			%StatusBar.hide()
			GlobalSignal.set_time_visibility.emit(false)
		else:
			%StatusBar.show()
			GlobalSignal.set_time_visibility.emit(true)

var hours: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#GlobalSignal.init_player_mp.connect(_init_player_mp)
	_player = get_tree().get_first_node_in_group("player")
	GlobalSignal.next_day.connect(_next_day)
	

#func _init_player_mp(_p:PlayerMP) -> void:
	#if _player:
		#return
	#_player = get_tree().get_first_node_in_group("player")
	#if _player is Player:
		#_player = _player as Player
	#elif _player is PlayerMP:
		#_player = _player as PlayerMP
		#_player.inputs_ui = inputs_ui


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta: float) -> void:
	#if not show_clock:
		#if time.visible:
			#time.hide()
		#return
	#else:
		#if not time.visible:
			#time.show()
	#var rounded_float = snappedf(level.time_of_day, 0.01)
	#var decimal = rounded_float - int(rounded_float)
	#var minutes = decimal * 100 * 0.6
	#hours = int(rounded_float)
	#
	#var hr_text: StringName
	#if hours == 0:
		#hr_text = "12"
	#elif hours < 10:
		#hr_text = "0" + str(hours)
	#elif hours >= 10 and hours <= 12:
		#hr_text = str(hours)
	#elif hours > 12:
		#hr_text = str(hours - 12)
	#if int(round(minutes)) < 10:
		#time.text = str(hr_text + ":0", int(round(minutes)))
	#else:
		#time.text = str(hr_text + ":", int(round(minutes)))
	

func _next_day(submit:bool) -> void:
	if not submit:
		next_day_ui.show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		GlobalSignal.freeze_player_camera.emit(true)


func _on_clock_timer_timeout() -> void:
	var rounded_float = snappedf(level.time_of_day, 0.0001)
	var decimal = rounded_float - int(rounded_float)
	var minutes = decimal * 100 * 0.6
	hours = int(rounded_float)
	
	var hr_text: StringName
	if hours == 0:
		hr_text = "12"
	elif hours < 10:
		hr_text = "0" + str(hours)
	elif hours >= 10 and hours <= 12:
		hr_text = str(hours)
	elif hours > 12:
		hr_text = str(hours - 12)
	var is_pm:bool = false
	if hours >= 12:
		is_pm = true
	if int(floor(minutes)) < 10:
		GlobalSignal.update_time.emit(str(hr_text + ":0", int(floor(minutes))), is_pm)
	else:
		GlobalSignal.update_time.emit(str(hr_text + ":", int(floor(minutes))), is_pm)
