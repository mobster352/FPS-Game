extends Node3D
class_name Interactable

const RETICLE_WHITE := Color(255,255,255)
const RETICLE_RED := Color(255,0,0)
const RETICLE_GREEN := Color(0.0, 1.0, 0.0, 1.0)

var surface_material_override:StandardMaterial3D
var stencil_outline_thickness:float = 0.01
var stencil_color:Color = Color.GREEN

func can_interact(_player: Player) -> bool:
	return false
	
func interact(_player: Player) -> void:
	pass
	
func reticle_color() -> Color:
	return RETICLE_WHITE

func interact2(_player: Player) -> void:
	pass

func enable_stencil() -> void:
	if surface_material_override:
		surface_material_override.stencil_mode = BaseMaterial3D.STENCIL_MODE_OUTLINE
		surface_material_override.stencil_color = stencil_color
		surface_material_override.stencil_outline_thickness = stencil_outline_thickness

func disable_stencil() -> void:
	if surface_material_override:
		surface_material_override.stencil_mode = BaseMaterial3D.STENCIL_MODE_DISABLED
