extends Weapon
class_name Pew

@export var animationTree: AnimationTree
#@export var player: Player

@export var flash_time = 0.05
@export var light: OmniLight3D
@export var emitter: GPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#player.weapon_fired.connect(add_muzzle_flash)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func shoot_animation() -> void:
	animationTree.set("parameters/ShootOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func add_muzzle_flash() -> void:
	light.visible = true
	emitter.emitting = true
	await get_tree().create_timer(flash_time).timeout
	light.visible = false
