extends Control

@onready var mouse_cursor: Sprite2D = $MouseCursor
var pc_mouse_pos:Vector2 = Vector2.ZERO
@onready var shop_control: Control = %ShopControl
@export var computer:Computer

func _ready() -> void:
	GlobalSignal.update_time.connect(_update_time)

func update_cursor_pos() -> void:
	mouse_cursor.position = pc_mouse_pos


func _on_shop_button_pressed() -> void:
	shop_control.show()


func _on_shop_close_button_pressed() -> void:
	shop_control.hide()


func _on_purchase_button_pressed() -> void:
	if computer:
		computer._on_purchase_button_pressed()


func _update_time(time:String, is_pm:bool) -> void:
	%TimeValue.text = time
	if is_pm:
		%TimeValue.text += " PM"
	else:
		%TimeValue.text += " AM"
