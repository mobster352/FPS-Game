extends Node3D
class_name Cookable

const RETICLE_WHITE := Color(255,255,255)
const RETICLE_RED := Color(255,0,0)
const RETICLE_GREEN := Color(0.0, 1.0, 0.0, 1.0)

var toppings: Array[StringName]

func can_cook() -> bool:
	return false
	
func cook(_player: Player) -> void:
	pass
	
func reticle_color() -> Color:
	return RETICLE_WHITE
