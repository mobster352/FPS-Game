extends Control

@onready var mouse_cursor: Sprite2D = $MouseCursor
var pc_mouse_pos:Vector2 = Vector2.ZERO


func _ready() -> void:
	pass # Replace with function body.

func update_cursor_pos() -> void:
	mouse_cursor.position = pc_mouse_pos
