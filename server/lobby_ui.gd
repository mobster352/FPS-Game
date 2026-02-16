extends Control
class_name LobbyUI

@export var lobby_name: String:
	set(ln):
		lobby_name = ln
		$Button/HBoxContainer2/LobbyName.text = ln
@export var num_players: int:
	set(np):
		num_players = np
		$Button/HBoxContainer2/NumPlayers.text = str(np) + "/" + str(max_players)
@export var button:Button

var max_players := 4
