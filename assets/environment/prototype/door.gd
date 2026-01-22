extends Interactable
class_name Door

const GREEN = Color.GREEN
const RED = Color.RED

@export var speed := 1.5
@export var is_locked := false
@export var number_required := 1
@export var money_required := 0
@export var label: Label3D

var in_range := false
var is_open := false
var interact_door := false
var elapsed := 0.0
var count := 0

@onready var player: Player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func _process(delta: float) -> void:
	if elapsed >= 1.0:
		interact_door = false
		is_open = not is_open
		elapsed = 0.0
	if interact_door:
		if is_open:
			basis = lerp(basis,basis.rotated(Vector3.UP, deg_to_rad(-90)).orthonormalized(), speed * delta)
		else:
			basis = lerp(basis,basis.rotated(Vector3.UP, deg_to_rad(90)).orthonormalized(), speed * delta)
		elapsed += speed * delta


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true
		if label:
			if player.money < money_required:
				label.modulate = RED
			else:
				label.modulate = GREEN
			if money_required != 0:
				label.show()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false
		if label:
			if money_required != 0:
				label.hide()


func door_interact() -> void:
	if not interact_door and not is_locked:
		interact_door = true


func close_door() -> void:
	if is_open:
		interact_door = true


func can_interact(_player: Player) -> bool:
	if in_range:
		player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.Interact, player.has_held_object())
	return in_range
	
func interact(_player: Player) -> void:
	if money_required != 0:
		if player.money >= money_required:
			player.update_money(-money_required)
			money_required = 0
			label.hide()
			door_interact()
	else:
		door_interact()
	
func reticle_color() -> Color:
	return RETICLE_GREEN

func interact2(_player: Player) -> void:
	if player.has_held_object():
		if player.item_slot.get_child_count() > 0:
			player.drop_item()
