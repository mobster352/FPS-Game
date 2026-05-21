extends Marker3D

@export var endPathMarker:Marker3D
@export var level_ui:Level_UI
@export var npcSpawnTimer:Timer

var npcs_node:Node3D
var npcs:Dictionary[String, NPC_Dummy]

func _ready() -> void:
	#GlobalSignal.open_store.connect(_open_store)
	GlobalSignal.close_store.connect(_close_store)
	
	npcs_node = get_parent()
	
	for skin:String in GlobalVar.npc_skins.keys():
		var npc_dummy:NPC_Dummy = preload("uid://dxnl4jurpfddl").instantiate()
		npc_dummy.dummy_scene = load(skin)
		npc_dummy.level_ui = level_ui
		npc_dummy.enable_npc(false)
		npcs_node.call_deferred("add_child", npc_dummy)
		npcs.set(skin, npc_dummy)
		
	npcSpawnTimer.start()
	
#func _open_store() -> void:
	#npcSpawnTimer.start()
	
func _close_store() -> void:
	npcSpawnTimer.stop()

func _on_npc_spawn_timer_timeout() -> void:
	npcSpawnTimer.wait_time = randi_range(3, 5)
	var stagger_chance = randi_range(0,3)
	if stagger_chance == 0:
		return
	var random_npc = GlobalVar.npc_skins.keys().pick_random()
	#var random_npc = "uid://bygykan821e7t"
	var npc:NPC_Dummy = npcs.get(random_npc)
	if npc.is_enabled:
		return
	npc.endPathMarker = endPathMarker
	npc.transform = transform
	npc.skin_uuid = random_npc
	npc.enable_npc(true)
