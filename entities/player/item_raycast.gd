extends RayCast3D

const RETICLE_WHITE := Color(255,255,255,0.5)
const RETICLE_RED := Color(255,0,0,0.5)
const RETICLE_GREEN := Color(0.0, 1.0, 0.0, 0.5)

#@export var reticle: ColorRect

@export var inputs_ui: InputsUI
#@export var placement_system:PlacementSystem

@export var player:PlayerMP

var can_place := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_process_rayCast()


func _process_rayCast() -> void:
	#reticle.color = RETICLE_WHITE

	if not is_colliding():
		return
		
	var target := get_collider()
	if not target:
		return
		
	#if placement_system:
		#if placement_system.toggle_build:
			#_handle_build_raycast(target)
			#return
	_handle_item_raycast(target)
	
func _handle_item_raycast(target: Node3D) -> void:
	can_place = false
	
	inputs_ui.update_actions.emit(inputs_ui.InputAction.None, player.has_held_object())
	
	#if player.has_held_object():
		#var item = player.item_slot.get_child(0)
		#if item.has_meta("place"):
			#if player.is_placing:
				#if player.preview_instance:
					#player.update_preview()
					#inputs_ui.update_actions.emit(inputs_ui.InputAction.Confirm)
				#if player.interact:
					#var is_placed = player.confirm_placement()
					#if is_placed:
						#player.interact = false
						#player.is_placing = false
				#elif player.drop_input:
					#player.is_placing = false
					#player.drop_input = false
					#get_tree().current_scene.remove_child(player.preview_instance)
				#return
			#else:
				#if player.interact and not target.has_node("Interactable"):
					#player.start_placement()
					#inputs_ui.update_actions.emit(inputs_ui.InputAction.Confirm)
					#player.is_placing = true
				#else:
					#if item.has_meta("pizzaboxes"):
						#inputs_ui.update_actions.emit(inputs_ui.InputAction.OnlyPlacement)
					#else:
						#inputs_ui.update_actions.emit(inputs_ui.InputAction.PrePlacement)
			#return
	
	var interactable := target as InteractableMP
	if not interactable:
		interactable = target.get_parent() as InteractableMP
	if not interactable and target.has_node("InteractableMP"):
		interactable = target.get_node("InteractableMP") as InteractableMP

	if interactable:
		if interactable.can_interact(player):
			#reticle.color = interactable.reticle_color()
			if player.interact:
				interactable.interact(player)
				player.interact = false
			if player.drop_input:
				interactable.interact2(player)
				player.drop_input = false

	var cook_input := Input.is_action_just_pressed("cook")
	
	var cookable := target as CookableMP
	if not cookable and target.has_node("CookableMP"):
		cookable = target.get_node("CookableMP")
	
	if cookable:
		if cookable.can_cook(player):
			#reticle.color = cookable.reticle_color()
			if cook_input:
				cookable.cook(player)

func _handle_build_raycast(target: Node3D) -> void:
	inputs_ui.update_actions.emit(inputs_ui.InputAction.None, player.has_held_object())
	
	var movable := target as Movable
	if not movable:
		movable = target.get_parent() as Movable
	if not movable and target.has_node("MovableMP"):
		movable = target.get_node("MovableMP") as Movable
	
	if movable:
		if movable.can_move():
			inputs_ui.update_actions.emit(inputs_ui.InputAction.PreMove)
			if player.interact:
				movable.move()
				player.interact = false
