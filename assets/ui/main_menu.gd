extends Control

signal show_load_game_menu

@export var menu_audio: AudioStreamPlayer
@export var main_menu: Control
@export var options_menu: Control
@onready var bg_texture: TextureRect = %BgTexture
@onready var steam: MarginContainer = %Steam

const BG_TEX_01:StringName = "uid://m0im0ucr4f4q"
const BG_TEX_02:StringName = "uid://dw7l4rby32olm"
const BG_TEX_03:StringName = "uid://3a1ije2qj36k"

var bg_tex_arr:Array

func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		get_tree().call_deferred("change_scene_to_file","uid://b10ibkxnixdiq")
	%StartGameButton.grab_focus()
	bg_tex_arr.append(BG_TEX_01)
	bg_tex_arr.append(BG_TEX_02)
	bg_tex_arr.append(BG_TEX_03)
	bg_texture.texture = load(bg_tex_arr.pick_random())
	if steamworks.is_steam_active:
		steam.show()
	else:
		steam.hide()


func _on_exit_button_pressed() -> void:
	get_tree().quit()



func _on_texture_button_mouse_entered() -> void:
	menu_audio.play()


func _on_multiplayer_button_pressed() -> void:
	get_tree().change_scene_to_file("uid://b10ibkxnixdiq")


func _on_start_game_button_pressed() -> void:
	#get_tree().change_scene_to_file("res://assets/ui/load_game_menu.tscn")
	hide()
	show_load_game_menu.emit()


func _on_settings_button_pressed() -> void:
	main_menu.hide()
	options_menu.show()



func _on_main_visibility_changed() -> void:
	if visible and %StartGameButton.is_inside_tree():
		%StartGameButton.grab_focus()


func _on_discord_texture_mouse_entered() -> void:
	%DiscordTexture.texture = load("res://assets/ui/discord2_hover.png")


func _on_discord_texture_mouse_exited() -> void:
	%DiscordTexture.texture = load("res://assets/ui/discord2.png")


func _on_load_game_menu_show_main_menu() -> void:
	show()


func _on_bg_timer_timeout() -> void:
	var random_tex:StringName = bg_tex_arr.pick_random()
	bg_texture.texture = load(random_tex)
