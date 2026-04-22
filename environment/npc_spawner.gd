extends Marker3D

@export var endPathMarker:Marker3D
@export var level_ui:Level_UI
@export var npcSpawnTimer:Timer

var skins:Array[String] = [
	"uid://bbedpve12ikmy",
	"uid://bxx4vua8kbs4h",
	"uid://vttdfwcbjkgk",
	"uid://bygykan821e7t",
	"uid://cwafteu2fqaol",
	"uid://btlcpec1pk0f4"
]

func _ready() -> void:
	GlobalSignal.open_store.connect(_open_store)
	GlobalSignal.close_store.connect(_close_store)
	
func _open_store() -> void:
	npcSpawnTimer.start()
	
func _close_store() -> void:
	npcSpawnTimer.stop()

func _on_npc_spawn_timer_timeout() -> void:
	var npc_dummy:NPC_Dummy = preload("uid://dxnl4jurpfddl").instantiate()
	npc_dummy.dummy_scene = load(skins.pick_random())
	npc_dummy.endPathMarker = endPathMarker
	npc_dummy.level_ui = level_ui
	npc_dummy.position = position + Vector3(0, 0, randf_range(-0.5,0.5))
	npc_dummy.rotation = rotation
	npcSpawnTimer.wait_time = randf_range(3, 15)
	get_parent().add_child(npc_dummy)
