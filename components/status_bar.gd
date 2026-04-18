extends Control

var player:Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignal.update_money.connect(_update_money)
	GlobalSignal.set_time_visibility.connect(_set_time_visibility)
	GlobalSignal.update_time.connect(_update_time)
	player = get_tree().get_first_node_in_group("player")
	if player:
		_update_money(player.money)
	
	

func _update_money(money:int) -> void:
	%MoneyValue.text = str(money)

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
