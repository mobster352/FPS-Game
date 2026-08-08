extends Interactable

@export var cash_register:CashRegister
@export var mesh:MeshInstance3D
@export var screen_camera: ScreenCamera
@export var screen_camera_ray_cast: RayCast3D

var player:Player

func _ready() -> void:
	GlobalSignal.update_is_cashier.connect(_update_is_cashier)
	player = get_tree().get_first_node_in_group("player")

func can_interact(_player: Player) -> bool:
	var result:bool = cash_register.in_range
	if result and not _player.is_cashier:
		_player.inputs_ui.update_actions.emit(_player.inputs_ui.InputAction.Interact, _player.has_held_object())
		if not surface_material_override:
			surface_material_override = mesh.get_surface_override_material(0)
			stencil_outline_thickness = 0.005
		enable_stencil()
	return result
	
func interact(_player: Player) -> void:
	if not _player.is_cashier:
		disable_stencil()
		_player.transform = cash_register.cashier_marker.global_transform
		_player.is_cashier = true
		_update_is_cashier(true)
		cash_register.set_register_visibility(true)

func _update_is_cashier(value:bool) -> void:
	screen_camera.reset_transform()
	if value:
		player.camera.current = false
		screen_camera.current = true
		player.itemRaycast = screen_camera_ray_cast
	else:
		screen_camera.current = false
		player.camera.current = true
		player.itemRaycast = player.initial_item_raycast
