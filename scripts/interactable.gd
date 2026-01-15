extends Node3D
class_name Interactable

const RETICLE_WHITE := Color(255,255,255)
const RETICLE_RED := Color(255,0,0)
const RETICLE_GREEN := Color(0.0, 1.0, 0.0, 1.0)

func can_interact() -> bool:
	return false
	
func interact(_player: Player) -> void:
	pass
	
func reticle_color() -> Color:
	return RETICLE_WHITE
