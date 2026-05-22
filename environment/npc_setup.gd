class_name NPCSetup
extends Node3D

@export var level_ui:Level_UI

var npcs:Dictionary[StringName, NPC_Dummy]
var npc_data:Dictionary[StringName, bool]

func _ready() -> void:
	GlobalSignal.close_store.connect(_close_store)
	for skin:StringName in GlobalVar.npc_skins.keys():
		var npc_dummy:NPC_Dummy = preload("uid://dxnl4jurpfddl").instantiate()
		npc_dummy.dummy_scene = load(skin)
		npc_dummy.level_ui = level_ui
		npc_dummy.enable_npc(false)
		add_child(npc_dummy)
		npcs.set(skin, npc_dummy)

	for uuid:StringName in npc_data.keys():
		if npc_data.get(uuid):
			if not npcs.has(uuid):
				push_error("NPC UUID not found: ", uuid)
				continue
			var npc_dummy:NPC_Dummy = npcs.get(uuid)
			npc_dummy.dummy.weapon.hide()

func _close_store() -> void:
	pass
