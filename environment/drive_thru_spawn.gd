class_name DriveThruSpawn
extends Marker3D

signal init_drive_thru_menu

const DRIVE_THRU_CUSTOMER = preload("uid://dyerpcqr0dhve")

@export var drive_thru_timer: Timer
@export var level_ui: Level_UI

var drive_thru_menu:DriveThruMenu

var food_item: Item

func _ready() -> void:
	GlobalSignal.open_store.connect(_open_store)


func _on_drive_thru_timer_timeout() -> void:
	if level_ui.hours >= 22:
		return
	if drive_thru_menu:
	#var new_customer:DriveThruCustomer = DRIVE_THRU_CUSTOMER.instantiate()
	#new_customer.timer = drive_thru_timer
	#add_child(new_customer)
		init_drive_thru_menu.emit(drive_thru_menu)
	else:
		drive_thru_timer.start()


func _open_store() -> void:
	_start_timer()


func _start_timer() -> void:
	drive_thru_timer.wait_time = 1#randf_range(15,60)
	drive_thru_timer.start()
