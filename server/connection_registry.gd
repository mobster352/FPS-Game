extends Node
class_name ConnectionRegistry

@export var server_timer: Timer

signal player_connected(peer_id:int, player_info:Dictionary)
signal player_disconnected(peer_id:int)
signal server_disconnected
signal server_started
signal login_response(is_logged_in:bool)

signal joined_game

const PORT = 7000
const GOOGLE_SERVER_IP = "35.196.53.168"
const LOCAL_IP = "127.0.0.1"

const DEFAULT_SERVER_IP = LOCAL_IP
const MAX_CONNECTIONS = 100

var players = []
var player_info = {"name": "", "peer_id": 0}
var players_loaded = 0

var users:Array[Dictionary]


func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	if OS.has_feature("dedicated_server"):
		users.append({"username":"Mob", "password": "test", "peer_id":0})
		users.append({"username":"Noob", "password": "test", "peer_id":0})
		users.append({"username":"Riv", "password": "test", "peer_id":0})
		users.append({"username":"Feurn", "password": "test", "peer_id":0})
		users.append({"username":"Lee", "password": "test", "peer_id":0})
		users.append({"username":"BiggShot", "password": "test", "peer_id":0})
	
		player_info.set("name", "Server")
		create_game()
		server_timer.start()


func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	players.append(1)
	player_connected.emit(1, player_info)
	
	server_started.emit()
	print("Starting Dedicated Server...")


func join_game(username:String):
	player_info.set("name", username)
	player_info.set("peer_id", multiplayer.get_unique_id())
	joined_game.emit()
	_add_player_to_server.rpc_id(1, multiplayer.get_unique_id(), username)


func login(username:String, password:String, address = "") -> void:
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return
	multiplayer.multiplayer_peer = peer
	await get_tree().create_timer(0.1).timeout
	_login.rpc_id(1, multiplayer.get_unique_id(), username, password)


@rpc("any_peer")
func _login(peer_id:int, username:String, password:String) -> void:
	for user in users:
		if user.get("username") == username and user.get("password") == password:
			_send_login_response.rpc_id(peer_id, true)
			return
	_send_login_response.rpc_id(peer_id, false)


@rpc
func _send_login_response(is_logged_in:bool) -> void:
	if is_logged_in:
		login_response.emit(true)
	else:
		login_response.emit(false)
		remove_multiplayer_peer()


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()


# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)
	if multiplayer.is_server():
		print("Player Joined")


func _on_player_disconnected(id):
	player_disconnected.emit(id)
	if multiplayer.is_server():
		_remove_player_from_server(id)
		print("Player Left")


func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	#players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)


func _on_connected_fail():
	remove_multiplayer_peer()


func _on_server_disconnected():
	remove_multiplayer_peer()
	players.clear()
	server_disconnected.emit()
	if multiplayer.is_server():
		print("Server Disconnected")


@rpc("any_peer")
func _add_player_to_server(peer_id:int, username:String) -> void:
	players.append(peer_id)
	for user in users:
		if user.get("username") == username:
			user.set("peer_id", peer_id)
			break


@rpc("any_peer")
func _remove_player_from_server(peer_id:int) -> void:
	players.remove_at(players.find(peer_id))
	for user in users:
		if user.get("peer_id") == peer_id:
			user.set("peer_id", 0)
			break


@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	#players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)


func check_player_still_connected(peer_id:int) -> bool:
	return players.has(peer_id)


func get_username(peer_id:int) -> String:
	for user in users:
		if user.get("peer_id") == peer_id:
			return user.get("username")
	return "N/A"


func get_usernames_from_peer_ids(peer_ids:Array) -> Array:
	var usernames:Array
	for peer_id in peer_ids:
		usernames.append(get_username(peer_id))
	return usernames
