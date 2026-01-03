extends CharacterBody3D

@export var dummy: Dummy
@export var hitbox: CollisionShape3D
@export var enemyBody: CollisionShape3D
#@export var detectionArea: Area3D
@export var shootTimer: Timer
@export var ray: RayCast3D
@export var weapon: Weapon

@onready var player: Player

var isAlive: bool

var health := 3

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	isAlive = true


func _process(_delta: float) -> void:
	if shootTimer.time_left > 0:
		look_at_player()

func take_damage(damage:int) -> void:
	health -= damage
	if health <= 0:
		#queue_free()
		dummy.death_animation()
		enemyBody.disabled = true
		hitbox.disabled = true
		shootTimer.stop()
		isAlive = false
	else:
		dummy.hit_animation()


func _on_shoot_timer_timeout() -> void:
	dummy.shoot_animation()
	weapon.add_muzzle_flash()
	
func calculate_damage() -> void:
	if ray.is_colliding():
		var target = ray.get_collider()
		if target:
			#player.take_damage(randi() % 2 + 1) # player takes 1 or 2 damage
			player.take_damage(1)


func _on_detection_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and isAlive:
		shootTimer.start()
		dummy.aiming_animation()


func _on_detection_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and isAlive:
		shootTimer.stop()
		dummy.idle_animation()


func look_at_player() -> void:
	var direction: Vector3 = position.direction_to(player.position)
	var target: Basis = Basis.looking_at(direction, Vector3.UP, true)
	basis = basis.slerp(target, 0.03).orthonormalized()


func _on_walk_timer_timeout() -> void:
	pass # Replace with function body.
