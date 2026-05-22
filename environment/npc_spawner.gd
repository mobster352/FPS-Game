extends Marker3D

@export var endPathMarker:Marker3D
@export var npcSpawnTimer:Timer
@export var npc_setup:NPCSetup
@export var items_marker:Marker3D

func _ready() -> void:
	#GlobalSignal.open_store.connect(_open_store)
	GlobalSignal.close_store.connect(_close_store)
	
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
	var npc:NPC_Dummy = npc_setup.npcs.get(random_npc)
	if npc.is_enabled:
		return
	npc.endPathMarker = endPathMarker
	npc.transform = transform
	npc.skin_uuid = random_npc
	npc.items_marker = items_marker
	npc.enable_npc(true)
