extends Control

var player:Player

func _ready() -> void:
	GlobalSignal.change_scene.connect(_change_scene)
	player = get_tree().get_first_node_in_group("player") as Player
	if player:
		%DayValue.text = str(player.playerData.day)

func _on_button_pressed() -> void:
	GlobalSignal.next_day.emit(true)

func _change_scene() -> void:
	get_tree().change_scene_to_file("res://environment/level_1.tscn")


func _on_visibility_changed() -> void:
	if visible:
		if player:
			%CustomersServedValue.text = str(player.customers_served)
			var profit = player.money - player.starting_money
			if profit < 0:
				%ProfitValue.text = "-$" + str(abs(profit))
				%ProfitValue.label_settings.font_color = Color(255,0,0)
			else:
				%ProfitValue.text = "$" + str(profit)
				%ProfitValue.label_settings.font_color = Color(0,255,0)
			if player.money < 0:
				%BalanceValue.text = "-$" + str(player.money)
				%BalanceValue.label_settings.font_color = Color(255,0,0)
			else:
				%BalanceValue.text = "$" + str(player.money)
				%BalanceValue.label_settings.font_color = Color(0,255,0)
