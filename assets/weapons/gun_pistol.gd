extends Weapon
class_name GunPistol

@export var flash_time = 0.05
@export var light: OmniLight3D
@export var emitter: GPUParticles3D

func _ready() -> void:
	ammo_count = 10
	max_ammo = 10
	ammo_reserves = 20
	has_ammo = true

func add_muzzle_flash() -> void:
	light.visible = true
	emitter.emitting = true
	await get_tree().create_timer(flash_time).timeout
	light.visible = false
