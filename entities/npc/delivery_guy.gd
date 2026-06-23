class_name DeliveryGuy
extends Node3D

@onready var dialogue_box: DialogueBox = $DialogueBox
@onready var pointer: Node3D = $Pointer
@onready var package_spawn: Marker3D = %PackageSpawn
@onready var delivery_timer: Timer = %DeliveryTimer

const PACKAGE = preload("uid://chvbwj2atdffs")

var quest:Quest
var room_number:int

var has_quest:bool = false
var is_quest_ready_to_complete:bool = false
var is_quest_complete:bool = false
var in_range:bool = false

func _ready() -> void:
	GlobalSignal.update_quest_ready.connect(_update_quest_ready)
	setup_new_delivery_quest()

func interact(_player:Player) -> void:
	if not is_quest_complete:
		if not has_quest:
			dialogue_box.enable()
			dialogue_box.show()
			has_quest = true
			dialogue_box.current_index += 1
			GlobalSignal.add_quest.emit(quest.quest_id, quest.quest_objective_id)
			pointer.hide()
			var new_package:Package = PACKAGE.instantiate()
			new_package.room_number = room_number
			new_package.starting_pos = package_spawn.global_transform
			package_spawn.add_child(new_package)
			return
	dialogue_box.enable(self)
	dialogue_box.show()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false


func _update_quest_ready(_quest_id:StringName, _quest_objective_id:StringName) -> void:
	if quest.quest_id != _quest_id:
		return
	if quest.quest_objective_id != _quest_objective_id:
		return
	is_quest_ready_to_complete = true
	is_quest_complete = true
	dialogue_box.current_index += 1
	delivery_timer.start()


func _on_delivery_timer_timeout() -> void:
	setup_new_delivery_quest()
	
func setup_new_delivery_quest() -> void:
	var arr:Array = ResourceManager.get_random_delivery_quest()
	quest = arr[0]
	room_number = arr[1]
	dialogue_box.dialogue_id = quest.dialogue_id
	dialogue_box.current_index = 0
	has_quest = false
	is_quest_ready_to_complete = false
	is_quest_complete = false
	pointer.show()
