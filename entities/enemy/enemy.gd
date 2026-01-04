extends CharacterBody3D

@export var dummy: Dummy
@export var enemyBody: CollisionShape3D
@export var shootTimer: Timer
@export var ray: RayCast3D
@export var weapon: Weapon
@export var navigation_agent: NavigationAgent3D
@export var walkTimer: Timer
@export var loot: Node3D
@export var throw_strength := 4

@onready var player: Player

var isAlive: bool
var health := 3
var player_detected := false

var item: Item

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	isAlive = true
	item = preload("res://assets/items/coin_a.tscn").instantiate()
	var material = StandardMaterial3D.new()
	material.albedo_texture = preload("res://assets/kaykit/misc/Dummy_prototypebits_texture.png")
	item.standardMaterial3D = material
	

func _process(_delta: float) -> void:
	if shootTimer.time_left > 0:
		look_at_target(player.position)


func _physics_process(delta: float) -> void:
	if not player_detected and isAlive:
		if global_position.distance_to(navigation_agent.get_next_path_position()) > 0.0:
			var destination = navigation_agent.get_next_path_position()
			var local_destination = destination - global_position
			var direction = local_destination.normalized()
			if global_position.distance_to(navigation_agent.get_final_position()) > 0.5:
				velocity = direction * 80.0 * delta
				move_and_slide()
				look_at_target(navigation_agent.get_next_path_position())
				dummy.walk_animation()
			else:
				dummy.idle_animation()
				if walkTimer.time_left <= 0:
					walkTimer.start()

func take_damage(damage:int, _target:CollisionShape3D) -> void:
	health -= damage
	if health <= 0:
		#queue_free()
		dummy.death_animation()
		enemyBody.disabled = true
		shootTimer.stop()
		walkTimer.stop()
		isAlive = false
		spawn_coin()
	else:
		dummy.hit_animation()


func spawn_coin() -> void:
	loot.add_child(item)
	var forward = global_transform.basis.z.normalized()
	for c in item.get_children():
		if c is RigidBody3D:
			c.apply_central_impulse(forward * (throw_strength / c.mass))


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
		player_detected = true


func _on_detection_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and isAlive:
		shootTimer.stop()
		dummy.idle_animation()
		player_detected = false


func look_at_target(pos: Vector3) -> void:
	var direction: Vector3 = position.direction_to(pos)
	var target: Basis = Basis.looking_at(direction, Vector3.UP, true)
	basis = basis.slerp(target, 0.05).orthonormalized()


func _on_walk_timer_timeout() -> void:
	if not player_detected:
		walkTimer.stop()
		navigation_agent.set_target_position(NavigationServer3D.map_get_random_point(navigation_agent.get_navigation_map(), 1, false))
