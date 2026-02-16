extends Control
class_name MultiplayerUI

@export var connection_registry: ConnectionRegistry
@export var lobby: Lobby
@export var level: Node
@export var main_menu_control:Control
@export var lobby_list_control:Control
@export var lobby_control:Control
@export var lobby_grid: GridContainer
@export var peer_id_label: Label
@export var lobby_vbox: VBoxContainer
@export var start_game_button: Button
@export var join_game_button: Button
@export var login_menu:Control
@export var username_line_edit:LineEdit
@export var password_line_edit:LineEdit

const LOBBY_UI_PATH = "uid://chd78wxs2t4bs"

var lobby_id:int = -1

func _ready() -> void:
	lobby.lobby_created.connect(_lobby_created)
	lobby.lobby_joined.connect(_lobby_joined)
	lobby.lobby_left.connect(_lobby_left)
	lobby.lobby_cleanup.connect(_lobby_cleanup)
	lobby.lobby_started.connect(_lobby_started)
	lobby.refresh_lobbies.connect(_refresh_lobbies)
	lobby.host_left.connect(_host_left)
	lobby.game_started.connect(_game_started)
	
	connection_registry.joined_game.connect(_joined_game)
	connection_registry.login_response.connect(_login_response)


func _on_start_game_button_pressed() -> void:
	lobby.start_lobby(lobby_id)
	start_game_button.hide()


func _on_join_game_button_pressed() -> void:
	lobby.join_game_in_progress(lobby_id, multiplayer.get_unique_id())


func _player_connected(peer_id:int, _player_info:Dictionary) -> void:
	if peer_id == multiplayer.get_unique_id():
		_on_refresh_lobby_button_pressed()


func _on_multiplayer_button_pressed() -> void:
	main_menu_control.hide()
	login_menu.show()


func _joined_game() -> void:
	_on_refresh_lobby_button_pressed()


func _on_create_lobby_button_pressed() -> void:
	lobby.create_lobby(multiplayer.get_unique_id())
	for label in lobby_vbox.get_children():
		label.queue_free()


func _lobby_created(_lobby_id:int) -> void:
	lobby_id = _lobby_id
	lobby_list_control.hide()
	lobby_control.show()
	var player_label = Label.new()
	player_label.text = connection_registry.player_info.get("name")
	lobby_vbox.add_child(player_label)
	start_game_button.show()


func _join_lobby_button_pressed(_lobby_id:int) -> void:
	lobby.join_lobby(_lobby_id, multiplayer.get_unique_id())


func _lobby_joined(_lobby_id:int, is_success:bool, players_in_lobby:Array, error_text:String) -> void:
	if is_success:
		lobby_id = _lobby_id
		lobby_list_control.hide()
		lobby_control.show()
		lobby.check_game_started(_lobby_id, multiplayer.get_unique_id())
	else:
		var error = preload("uid://cih8jcma476vk").instantiate() as ErrorUI
		error.label_text = error_text
		add_child(error)
		return
	for label:Label in lobby_vbox.get_children():
		label.queue_free()
	for p in players_in_lobby:
		var player_label = Label.new()
		player_label.text = str(p)
		lobby_vbox.add_child(player_label)


func _game_started(has_game_started:bool) -> void:
	if has_game_started:
		join_game_button.show()


func _on_leave_lobby_button_pressed() -> void:
	lobby.leave_lobby(lobby_id, multiplayer.get_unique_id())
	lobby_control.hide()
	lobby_list_control.show()
	start_game_button.hide()
	join_game_button.hide()
	lobby_id = -1
	_on_refresh_lobby_button_pressed()


func _lobby_left(_lobby_id:int, username:String) -> void:
	for label:Label in lobby_vbox.get_children():
		if label.text == username:
			label.queue_free()
			return


func _host_left() -> void:
	lobby_control.hide()
	lobby_list_control.show()
	start_game_button.hide()
	join_game_button.hide()
	lobby_id = -1
	_on_refresh_lobby_button_pressed()
	add_error_message("Host has left the game")
	for label:Label in lobby_vbox.get_children():
		label.queue_free()


func _lobby_cleanup() -> void:
	for label in lobby_vbox.get_children():
		label.queue_free()
	_on_refresh_lobby_button_pressed()


func _lobby_started(_lobby_id:int, peer_id:int) -> void:
	if peer_id == multiplayer.get_unique_id():
		hide()
		start_game_button.hide()
		join_game_button.hide()


func _on_refresh_lobby_button_pressed() -> void:
	for l in lobby_grid.get_children():
		l.queue_free()
	lobby.get_all_lobbies(multiplayer.get_unique_id())


func _refresh_lobbies(peer_id:int, lobby_ids:Array, num_players:Array, host_names:Array) -> void:
	if peer_id != multiplayer.get_unique_id():
		return
	var index := 0
	for id in lobby_ids:
		var lobby_ui = preload(LOBBY_UI_PATH).instantiate() as LobbyUI
		lobby_ui.lobby_name = str(host_names[index])
		lobby_ui.num_players = num_players[index]
		lobby_ui.button.pressed.connect(_join_lobby_button_pressed.bind(id))
		lobby_grid.add_child(lobby_ui)
		index += 1
	lobby_grid.add_child(Control.new())


func _on_menu_button_pressed() -> void:
	multiplayer.multiplayer_peer.close()
	main_menu_control.show()
	lobby_list_control.hide()


func _on_exit_to_desktop_button_pressed() -> void:
	get_tree().quit()


func _on_connect_button_pressed() -> void:
	var username = username_line_edit.text
	var password = password_line_edit.text
	if not username or not password:
		add_error_message("Missing Username / Password")
		return
	connection_registry.login(username, password)

func add_error_message(error_message:String) -> void:
	var error = preload("uid://cih8jcma476vk").instantiate() as ErrorUI
	error.label_text = error_message
	add_child(error)


func _login_response(is_logged_in:bool) -> void:
	if is_logged_in:
		var username = username_line_edit.text
		peer_id_label.text = username
		connection_registry.join_game(username)
		login_menu.hide()
		lobby_list_control.show()
	else:
		add_error_message("Username / Password does not exist")


func _on_mob_button_pressed() -> void:
	username_line_edit.text = "Mob"
	connection_registry.login("Mob", "test")


func _on_noob_button_pressed() -> void:
	username_line_edit.text = "Noob"
	connection_registry.login("Noob", "test")


func _on_singleplayer_button_pressed() -> void:
	connection_registry.create_singleplayer_game()
	lobby.create_singleplayer_lobby(1)
