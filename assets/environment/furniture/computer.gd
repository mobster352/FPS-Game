extends Node3D
class_name Computer

signal select_store_item(store_item: StoreItem, price: int, selected: bool)

@export var sub_viewport: SubViewportContainer
@export var computer_camera: Camera3D
@export var cart_total_label: Label
@export var cart_vbox: VBoxContainer
@export var cart_items: Panel
@export var total_price_label: Label
@export var remaining_money_label: Label
@export var balance_label: Label

var in_range := false
var player: Player

var cart_total := 0:
	set(value):
		cart_total = value
		cart_total_label.text = "$" + str(cart_total)
		total_price_label.text = "$" + str(cart_total)
		if player:
			remaining_money_label.text = "$" + str(player.money - cart_total)
			balance_label.text = "$" + str(player.money)

enum StoreItem {
	None,
	RollingPin,
	Dough,
	Tomato,
	Cheese,
	Pepperoni,
	Mushroom
}

func _ready() -> void:
	sub_viewport.hide()
	select_store_item.connect(_select_store_item)
	balance_label.text = "$0"
	total_price_label.text = "$0"
	remaining_money_label.text = "$0"
	cart_total = 0
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") and sub_viewport.visible:
		_on_home_button_pressed()
	
func interact(_player: Player) -> void:
	player = _player
	sub_viewport.show()
	computer_camera.current = true
	player.freeze_camera = true
	player.reticle.hide()
	player.ui.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	balance_label.text = "$" + str(player.money)
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false


func _on_home_button_pressed() -> void:
	sub_viewport.hide()
	player.camera.current = true
	player.freeze_camera = false
	player.reticle.show()
	player.ui.show()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_cart_button_pressed() -> void:
	cart_items.visible = not cart_items.visible
	
func _select_store_item(store_item: StoreItem, price: int, selected: bool) -> void:
	if selected:
		cart_total += price
		var new_label : Label = Label.new()
		new_label.text = get_store_item_name(store_item)
		cart_vbox.add_child(new_label)
	else:
		cart_total -= price
		for label:Label in cart_vbox.get_children():
			if label.text == get_store_item_name(store_item):
				cart_vbox.remove_child(label)
				return

func get_store_item_name(store_item:StoreItem) -> StringName:
	if store_item == StoreItem.None:
		return "Invalid Item"
	elif store_item == StoreItem.RollingPin:
		return "Rolling Pin"
	elif store_item == StoreItem.Dough:
		return "Dough"
	elif store_item == StoreItem.Tomato:
		return "Tomato"
	elif store_item == StoreItem.Cheese:
		return "Cheese"
	elif store_item == StoreItem.Pepperoni:
		return "Pepperoni"
	elif store_item == StoreItem.Mushroom:
		return "Mushroom"
	else:
		return "Invalid Item"


func _on_purchase_button_pressed() -> void:
	if player.money - cart_total >= 0:
		player.update_money(-cart_total)
		cart_total = 0
		for label in cart_vbox.get_children():
			cart_vbox.remove_child(label)
