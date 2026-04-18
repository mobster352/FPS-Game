extends Control

var player:Player
var money_increment_start_pos:Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignal.update_money.connect(_update_money)
	GlobalSignal.update_money_floating_text.connect(_update_money_floating_text)
	GlobalSignal.set_time_visibility.connect(_set_time_visibility)
	GlobalSignal.update_time.connect(_update_time)
	player = get_tree().get_first_node_in_group("player")
	if player:
		_update_money(player.money)
	money_increment_start_pos = %MoneyIncrement.position
	

func _update_money(money:int) -> void:
	%MoneyValue.text = str(money)

func _update_money_floating_text(money:int) -> void:
	if money > 0:
		%MoneyIncrement.text = "+" + str(money)
		%MoneyIncrement.label_settings.font_color = Color.GREEN
	else:
		%MoneyIncrement.text = str(money)
		%MoneyIncrement.label_settings.font_color = Color.RED
	%MoneyIncrement.position = money_increment_start_pos
	%MoneyIncrement.show()
	var tween = create_tween()
	tween.tween_property(%MoneyIncrement, "position", Vector2(0, position.y + 30), 1.0)
	await get_tree().create_timer(1).timeout
	%MoneyIncrement.hide()


func _set_time_visibility(_visible:bool) -> void:
	if %TimeValue.visible != _visible:
		%TimeValue.visible = _visible
	if  %TimeValue.visible:
		show()
		
func _update_time(time:String, is_pm:bool) -> void:
	%TimeValue.text = time
	if is_pm:
		%TimeValue.text += " PM"
	else:
		%TimeValue.text += " AM"
