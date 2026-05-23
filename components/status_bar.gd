extends Control

var player:Player
var money_increment_start_pos:Vector2
var xp_increment_start_pos:Vector2
var max_xp_value:int = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignal.update_money.connect(_update_money)
	GlobalSignal.update_money_floating_text.connect(_update_money_floating_text)
	GlobalSignal.set_time_visibility.connect(_set_time_visibility)
	GlobalSignal.update_time.connect(_update_time)
	GlobalSignal.add_xp.connect(_add_xp)
	GlobalSignal.freeze_player_camera.connect(_freeze_player_camera)
	player = get_tree().get_first_node_in_group("player")
	if player:
		_update_money(player.money)
		update_max_xp_value()
		%LevelValue.text = str(player.level)
		%LevelProgressBar.value = player.xp
	money_increment_start_pos = %MoneyIncrement.position
	xp_increment_start_pos = %LevelIncrement.position
	

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
	tween.tween_property(%MoneyIncrement, "position", %MoneyIncrement.position + Vector2(0, %MoneyIncrement.position.y - 100), 2.0)
	await get_tree().create_timer(1).timeout
	%MoneyIncrement.hide()
	
func _update_xp_floating_text(xp:int) -> void:
	if xp > 0:
		%LevelIncrement.text = "+" + str(xp)
		%LevelIncrement.label_settings.font_color = Color.GREEN
	else:
		%LevelIncrement.text = str(xp)
		%LevelIncrement.label_settings.font_color = Color.RED
	%LevelIncrement.position = xp_increment_start_pos
	%LevelIncrement.show()
	var tween = create_tween()
	tween.tween_property(%LevelIncrement, "position", %LevelIncrement.position + Vector2(0, %LevelIncrement.position.y - 100), 2.0)
	await get_tree().create_timer(1).timeout
	%LevelIncrement.hide()


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


func update_max_xp_value() -> void:
	@warning_ignore("narrowing_conversion")
	max_xp_value = 50 * pow(player.level, 2)
	%LevelProgressBar.max_value = max_xp_value


func _add_xp(value:int) -> void:
	if player.xp + value >= max_xp_value:
		player.xp = (player.xp + value) - max_xp_value
		player.level += 1
		GlobalSignal.level_up.emit(player.level)
		%LevelValue.text = str(player.level)
		update_max_xp_value()
	else:
		player.xp += value
	%LevelProgressBar.value = player.xp
	_update_xp_floating_text(value)


func _freeze_player_camera(is_freeze:bool) -> void:
	if is_freeze:
		hide()
	else:
		show()
