extends Node3D
class_name LevelMP

@export var players_node:Node3D
@export var objects_node:Node3D

@export var rolling_pin_marker: Marker3D

const SPAWN_RANDOM := 5.0

var lobby_id:int
var players:Array
var objects:Array[Dictionary]

func _ready() -> void:
	if not multiplayer.is_server():
		GlobalSignal.remove_object_from_level.connect(_remove_object_from_level)
		return
	if OS.has_feature("dedicated_server"):
		players.append(1)
	spawn_objects()

func _exit_tree():
	if not multiplayer.is_server():
		return


func add_player(id: int, username:String):
	if players.has(id):
		return
	players.append(id)
	var character = preload("uid://ckmeyre76mhly").instantiate() as PlayerMP
	character.player = id
	var pos := Vector2.from_angle(randf() * 2 * PI)
	character.position = Vector3(pos.x * SPAWN_RANDOM * randf(), 0, pos.y * SPAWN_RANDOM * randf())
	character.name = str(id)
	character.server_synchronizer.set_multiplayer_authority(1)
	character.name_label.text = username
	for peer_id in players:
		character.server_synchronizer.set_visibility_for(peer_id, true)
		character.player_input_synchronizer.set_visibility_for(peer_id, true)
	players_node.add_child(character, true)
	for player:PlayerMP in players_node.get_children():
		player.server_synchronizer.set_visibility_for(id, true)
		player.player_input_synchronizer.set_visibility_for(id, true)
	for peer_id in players:
		if peer_id != 1:
			_add_player_to_peers.rpc_id(peer_id, id)
			for object in objects:
				var sync = object.get("object").get_node("MultiplayerSynchronizer") as MultiplayerSynchronizer
				sync.set_visibility_for(peer_id, true)
	
func del_player(id: int):
	if not players.has(id):
		return
	if not players_node.has_node(str(id)):
		return
	for player:PlayerMP in players_node.get_children():
		player.server_synchronizer.set_visibility_for(id, false)
		player.player_input_synchronizer.set_visibility_for(id, false)
	for peer_id in players:
		if peer_id != 1:
			_remove_player_from_peers.rpc_id(peer_id, id)
	players_node.get_node(str(id)).queue_free()
	players.remove_at(players.find(id))

func setup(_lobby_id:int) -> void:
	lobby_id = _lobby_id

@rpc
func _add_player_to_peers(peer_id:int) -> void:
	for player:PlayerMP in players_node.get_children():
		player.server_synchronizer.set_multiplayer_authority(1)
		player.server_synchronizer.set_visibility_for(peer_id, true)
		player.player_input_synchronizer.set_visibility_for(peer_id, true)
		player.server_synchronizer.set_visibility_for(1, true)
		player.player_input_synchronizer.set_visibility_for(1, true)
	
@rpc
func _remove_player_from_peers(_peer_id:int) -> void:
	#for player:PlayerMP in players_node.get_children():
		#player.server_synchronizer.set_visibility_for(peer_id, false)
		#player.player_input_synchronizer.set_visibility_for(peer_id, false)
	pass


func spawn_objects() -> void:
	var id := 1
	var rolling_pin = preload("uid://5egw1id8hdbg").instantiate() as Item
	var sync = rolling_pin.get_node("MultiplayerSynchronizer") as MultiplayerSynchronizer
	sync.set_visibility_for(1, true)
	rolling_pin.position = rolling_pin_marker.position
	rolling_pin.id = id
	rolling_pin.name = str(id)
	objects_node.add_child(rolling_pin, true)
	objects.append({
		"object": rolling_pin,
		"id": id
	})


func get_object_at_id(id:int) -> Dictionary:
	for object in objects:
		if object.get("id") == id:
			return object
	return {}


@rpc("any_peer")
func _remove_item_from_server(id:int) -> void:
	var object_dict = get_object_at_id(id)
	if object_dict:
		var object = object_dict.get("object") as Node3D
		objects_node.remove_child(object)
		object.queue_free()
		objects.remove_at(objects.find(object_dict))


func _remove_object_from_level(id:int) -> void:
	_remove_item_from_server.rpc_id(1, id)
