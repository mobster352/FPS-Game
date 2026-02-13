extends Node3D
class_name LevelMP

@export var players_node:Node3D

const SPAWN_RANDOM := 5.0

var lobby_id:int
var players:Array

func _ready() -> void:
	players.append(1)
	if not multiplayer.is_server():
		return

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
	for player:Player in players_node.get_children():
		player.server_synchronizer.set_visibility_for(id, true)
		player.player_input_synchronizer.set_visibility_for(id, true)
	for peer_id in players:
		if peer_id != 1:
			_add_player_to_peers.rpc_id(peer_id, id)
	
func del_player(id: int):
	if not players.has(id):
		return
	if not players_node.has_node(str(id)):
		return
	for player:Player in players_node.get_children():
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
	for player:Player in players_node.get_children():
		player.server_synchronizer.set_multiplayer_authority(1)
		player.server_synchronizer.set_visibility_for(peer_id, true)
		player.player_input_synchronizer.set_visibility_for(peer_id, true)
		player.server_synchronizer.set_visibility_for(1, true)
		player.player_input_synchronizer.set_visibility_for(1, true)
	
@rpc
func _remove_player_from_peers(_peer_id:int) -> void:
	#for player:Player in players_node.get_children():
		#player.server_synchronizer.set_visibility_for(peer_id, false)
		#player.player_input_synchronizer.set_visibility_for(peer_id, false)
	pass
