extends Interactable

@export var package_marker:PackageMarker
@onready var box_c_outline: Node3D = %Box_C_Outline

var in_range:bool = false
var quest_id:StringName
var quest_objective_id:StringName
var delivery_quest:DeliveryQuest

var quest_ids:Array

func _ready() -> void:
	GlobalSignal.add_quest.connect(_add_quest)
	quest_ids.append(QuestIds.DELIVER_PACKAGE_101)
	quest_ids.append(QuestIds.DELIVER_PACKAGE_102)
	quest_ids.append(QuestIds.DELIVER_PACKAGE_103)
	quest_ids.append(QuestIds.DELIVER_PACKAGE_104)
	quest_ids.append(QuestIds.DELIVER_PACKAGE_201)
	quest_ids.append(QuestIds.DELIVER_PACKAGE_202)
	quest_ids.append(QuestIds.DELIVER_PACKAGE_203)
	quest_ids.append(QuestIds.DELIVER_PACKAGE_204)

func _process(_delta: float) -> void:
	if box_c_outline.visible:
		box_c_outline.hide()

func can_interact(player: Player) -> bool:
	if in_range:
		if player.has_held_object():
			if player.get_held_object_mesh_name() == "package_mesh":
				player.inputs_ui.update_actions.emit(player.inputs_ui.InputAction.Interact, player.has_held_object())
				box_c_outline.show()
				return true
	return false
	
func interact(player: Player) -> void:
	if not player.has_held_object():
		return
	if player.get_held_object_mesh_name() != "package_mesh":
		return
	if not quest_id:
		return
	GlobalSignal.update_quest_ready.emit(quest_id, quest_objective_id)
	
	var obj_passed:bool
	if delivery_quest.room_number == package_marker.room_number:
		obj_passed = true
		if steamworks.is_steam_active:
			steamworks.set_statistic("FIRST_DELIVERY_STAT")
	else:
		obj_passed = false
	GlobalSignal.update_quest_objective.emit(quest_id, quest_objective_id, obj_passed)
	
	var package:Package = GlobalVar.get_item_from_mesh(player.get_held_object_mesh_name())
	package.is_disabled = true
	package.room_number = int(player.get_held_object().get_child(0).text)
	add_child(package)
	package.room_label.no_depth_test = false
	
	player.get_held_object().queue_free()
	
	quest_id = ""
	quest_objective_id = ""
	await get_tree().create_timer(30).timeout
	package.queue_free()
	
func interact2(_player: Player) -> void:
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false


func _add_quest(_quest_id:StringName, _quest_objective_id:StringName) -> void:
	if quest_ids.has(_quest_id):
		quest_id = _quest_id
		quest_objective_id = _quest_objective_id
		delivery_quest = ResourceManager.get_delivery_quest(quest_objective_id)
