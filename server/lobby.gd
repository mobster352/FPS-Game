extends Node
class_name Lobby

@export var level_node: Node
@export var connection_registry: ConnectionRegistry


signal lobby_created(lobby_id:int)
signal lobby_joined(lobby_id:int, is_success:bool, players_in_lobby:Array, error_text:String)
signal lobby_left(lobby_id:int, username:String)
signal lobby_cleanup(lobby_id:int)
signal lobby_started(lobby_id:int, peer_id:int)
signal refresh_lobbies(peer_id:int, lobby_ids:Array, num_players:Array, host_names:Array)

signal host_left
signal game_started(has_game_started:bool)

var lobbies = {}
var lobby_index = 0


func _ready():
	pass


func create_lobby(peer_id:int) -> void:
	_create_lobby.rpc_id(1, peer_id)


@rpc("any_peer")
func _create_lobby(peer_id:int) -> void:
	var lobby_id = lobby_index
	var lobby = {
		"id": lobby_id,
		"players": [peer_id],
		"instance": null,
		"state": "waiting",
		"host": peer_id,
		"hostname": connection_registry.get_username(peer_id)
	}
	lobbies[lobby_id] = lobby
	lobby_index += 1
	_send_new_lobby_to_peer.rpc_id(peer_id, lobby_id)


@rpc
func _send_new_lobby_to_peer(lobby_id:int) -> void:
	lobby_created.emit(lobby_id)


func join_lobby(lobby_id:int, peer_id:int):
	_join_lobby.rpc_id(1, lobby_id, peer_id)


@rpc("any_peer")
func _join_lobby(lobby_id:int, peer_id:int) -> void:
	if not lobbies.get(lobby_id):
		_send_join_lobby_to_peer.rpc_id(peer_id, lobby_id, false, [], "Lobby does not exist")
		return
	if get_num_players_in_lobby(lobby_id) >= 4:
		_send_join_lobby_to_peer.rpc_id(peer_id, lobby_id, false, [], "Lobby is full")
		return
	lobbies[lobby_id]["players"].append(peer_id)
	for id in lobbies[lobby_id]["players"]:
		_send_join_lobby_to_peer.rpc_id(id, lobby_id, true, connection_registry.get_usernames_from_peer_ids(lobbies[lobby_id]["players"]))


@rpc
func _send_join_lobby_to_peer(lobby_id:int, is_success:bool, players_in_lobby:Array, error_text:String = "") -> void:
	lobby_joined.emit(lobby_id, is_success, players_in_lobby, error_text)


func leave_lobby(lobby_id:int, peer_id:int) -> void:
	_leave_lobby.rpc_id(1, lobby_id, peer_id)


@rpc("any_peer", "reliable", "call_local")
func _leave_lobby(lobby_id:int, peer_id:int) -> void:
	var index = lobbies[lobby_id]["players"].find(peer_id)
	lobbies[lobby_id]["players"].remove_at(index)
	if lobbies[lobby_id]["players"].size() == 0:
		_send_lobby_left_to_peer.rpc_id(peer_id, lobby_id, connection_registry.get_username(peer_id))
		_cleanup_lobby(lobby_id)
		_remove_game_from_peer.rpc_id(peer_id)
	else:
		if lobbies[lobby_id]["host"] == peer_id:
			for p in lobbies[lobby_id]["players"]:
				_send_host_left_to_peer.rpc_id(p)
				_cleanup_lobby(lobby_id)
				_remove_game_from_peer.rpc_id(peer_id)
			_send_lobby_left_to_peer.rpc_id(peer_id, lobby_id, connection_registry.get_username(peer_id))
		else:
			for p in lobbies[lobby_id]["players"]:
				_send_lobby_left_to_peer.rpc_id(p, lobby_id, connection_registry.get_username(peer_id))
			var game = lobbies[lobby_id]["instance"] as LevelMP
			if game:
				game.del_player(peer_id)
			_remove_game_from_peer.rpc_id(peer_id)


@rpc
func _remove_game_from_peer() -> void:
	for level in level_node.get_children():
		level.queue_free()


@rpc
func _send_lobby_left_to_peer(lobby_id:int, username:String) -> void:
	lobby_left.emit(lobby_id, username)


@rpc
func _send_host_left_to_peer() -> void:
	host_left.emit()


func _cleanup_lobby(lobby_id:int):
	if not lobbies.get(lobby_id):
		return
	var instance = lobbies[lobby_id]["instance"]
	if instance:
		instance.queue_free()
	lobbies.erase(lobby_id)


@rpc
func _send_cleanup_lobby_to_peer() -> void:
	lobby_cleanup.emit()


func start_lobby(lobby_id:int) -> void:
	_start_lobby.rpc_id(1, lobby_id)


@rpc("any_peer", "reliable")
func _start_lobby(lobby_id:int):
	if not multiplayer.is_server():
		return
		
	var level = lobbies[lobby_id]["instance"]
	if level:
		for c in level.get_children():
			level.remove_child(c)
			c.queue_free()
		level.queue_free()

	var game = preload("uid://2ycx0wai2x7s").instantiate() as LevelMP
	game.name = "Lobby"+str(lobby_id)
	level_node.add_child(game, true)
	
	lobbies[lobby_id]["instance"] = game
	lobbies[lobby_id]["state"] = "running"
	
	for peer_id in lobbies[lobby_id]["players"]:
		_lobby_started.rpc_id(peer_id, lobby_id, lobbies[lobby_id]["players"], connection_registry.get_username(peer_id))
	
	game.setup(lobby_id)


@rpc("reliable")
func _lobby_started(lobby_id:int, players_in_lobby:Array, username:String):
	if multiplayer.is_server():
		return
	var id =  multiplayer.get_unique_id()
	if not players_in_lobby.has(id):
		return
	var game = preload("uid://2ycx0wai2x7s").instantiate() as LevelMP
	game.name = "Lobby"+str(lobby_id)
	level_node.add_child(game, true)
	_add_player.rpc_id(1, id, lobby_id, username)
	lobby_started.emit(lobby_id, id)


func join_game_in_progress(lobby_id:int, peer_id:int) -> void:
	var game = preload("uid://2ycx0wai2x7s").instantiate() as LevelMP
	game.name = "Lobby"+str(lobby_id)
	level_node.add_child(game, true)
	_add_player.rpc_id(1, peer_id, lobby_id, connection_registry.player_info.get("name"))
	lobby_started.emit(lobby_id, peer_id)


@rpc("any_peer")
func _add_player(peer_id:int, lobby_id:int, username:String) -> void:
	if not multiplayer.is_server():
		return
	lobbies[lobby_id]["instance"].add_player(peer_id, username)


func get_num_players_in_lobby(lobby_id:int) -> int:
	return lobbies[lobby_id]["players"].size()


func get_all_lobbies(peer_id:int) -> void:
	get_lobbies_from_server.rpc_id(1, peer_id)


@rpc("any_peer")
func get_lobbies_from_server(peer_id:int) -> void:
	var lobby_ids: Array
	var num_players: Array
	var host_names: Array
	for lobby_id in lobbies:
		var players_in_lobby = get_num_players_in_lobby(lobbies[lobby_id].get("id"))
		if players_in_lobby == 4:
			continue
		lobby_ids.append(lobbies.get(lobby_id).get("id"))
		num_players.append(players_in_lobby)
		host_names.append(lobbies.get(lobby_id).get("hostname"))
	send_lobbies_to_peer.rpc_id(peer_id, lobby_ids, num_players, host_names)


@rpc
func send_lobbies_to_peer(lobby_ids:Array, num_players:Array, host_names:Array) -> void:
	refresh_lobbies.emit(multiplayer.get_unique_id(), lobby_ids, num_players, host_names)


func _on_server_timer_timeout() -> void:
	#for p in players:
		#print(p)
	#for l in lobbies:
		#print(l)
	#if lobbies.size() == 0:
		#print("No lobbies found")
	for lobby_id in lobbies:
		if not connection_registry.check_player_still_connected(lobbies.get(lobby_id).get("host")):
			leave_lobby(lobby_id, lobbies.get(lobby_id).get("host"))
		else:
			for peer_id in lobbies.get(lobby_id).get("players"):
				if not connection_registry.check_player_still_connected(peer_id):
					leave_lobby(lobby_id, peer_id)


func check_game_started(lobby_id:int, peer_id:int) -> void:
	_check_game_started_server.rpc_id(1, lobby_id, peer_id)


@rpc("any_peer")
func _check_game_started_server(lobby_id:int, peer_id:int) -> void:
	_send_game_started_to_peer.rpc_id(peer_id, lobbies.get(lobby_id).get("state") == "running")


@rpc
func _send_game_started_to_peer(has_game_started:bool) -> void:
	game_started.emit(has_game_started)
