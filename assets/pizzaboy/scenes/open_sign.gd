extends Node3D
class_name OpenSign

@export var sign_text: MeshInstance3D
@export var blue_background: MeshInstance3D
@export var level: Level

var is_sign_on := false
var in_range := false
var quest_log:QuestLog

func _ready() -> void:
	quest_log = get_tree().get_first_node_in_group("quest_log")

func interact() -> void:
	if not is_sign_on:
		open_store()
		level.can_advance_time = is_sign_on
		GlobalSignal.open_store.emit()
		if quest_log.active_quest_id == Quest.QuestIds.OPEN_PIZZERIA:
			quest_log.update_quest(Quest.QuestIds.OPEN_PIZZERIA)
	elif level.time_of_day > 22:
		GlobalSignal.next_day.emit(false)
		if quest_log.active_quest_id == Quest.QuestIds.CLOSE_PIZZERIA:
			quest_log.update_quest(Quest.QuestIds.CLOSE_PIZZERIA)

func open_store() -> void:
	is_sign_on = not is_sign_on
	var sign_material = sign_text.get_surface_override_material(0) as StandardMaterial3D
	var blue_material = blue_background.get_surface_override_material(0) as StandardMaterial3D
	if sign_material:
		sign_material.emission_enabled = is_sign_on
	if blue_material:
		blue_material.emission_enabled = is_sign_on


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false
