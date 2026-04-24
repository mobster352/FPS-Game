extends Button

@export var store_item:StoreItem

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("tab_left"):
		get_viewport().set_input_as_handled()
		if not store_item.is_locked:
			store_item._on_decrement_item_pressed()
	elif event.is_action_pressed("tab_right"):
		get_viewport().set_input_as_handled()
		if not store_item.is_locked:
			store_item._on_increment_item_pressed()
