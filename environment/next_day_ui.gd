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
	var old_level:Node3D = get_node("/root/Node/Game/Level")
	var foreground:ColorRect = get_node("/root/Node/CanvasLayer/Foreground")
	var tween = create_tween()
	tween.tween_property(foreground, "color:a", 1.0, 0.5)
	await tween.finished
	old_level.name = "oldLevel"
	old_level.queue_free()
	GlobalSignal.spawn_new_level.emit()


func _on_visibility_changed() -> void:
	if visible:
		if player:
			%LevelValue.text = str(player.level)
			%CustomersServedValue.text = str(player.customers_served)
			%CustomersSatisfiedValue.text = str(player.customers_satisfied)
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
			%Button.grab_focus()
