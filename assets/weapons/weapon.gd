extends Node3D
class_name Weapon

@export var ui: UI

var max_ammo: int
var ammo_count: int:
	set(value):
		ammo_count = value
		if ui:
			ui.update_ammo(value, ammo_reserves)

var ammo_reserves: int:
	set(value):
		ammo_reserves = value
		if ui:
			ui.update_ammo(ammo_count, value)
var has_ammo: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func shoot_animation() -> void:
	pass

func add_muzzle_flash() -> void:
	pass

func equip() -> void:
	show()
	if has_ammo:
		ui.ammo_label.show()
	ui.show_hp(true)
	
func unequip() -> void:
	hide()
	if has_ammo:
		ui.ammo_label.hide()
	ui.show_hp(false)
