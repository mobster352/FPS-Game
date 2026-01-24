extends Node3D
class_name Computer

signal increment_store_item(store_item: GlobalVar.StoreItem, price: int, quantity: int)
signal decrement_store_item(store_item: GlobalVar.StoreItem, price: int, quantity: int)

@export var sub_viewport: SubViewportContainer
@export var cart_total_label: Label
@export var cart_vbox: VBoxContainer
@export var cart_items: Panel
@export var total_price_label: Label
@export var remaining_money_label: Label
@export var balance_label: Label
@export var hover_audio: AudioStreamPlayer

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
			
var order_items: Array[Dictionary]

func _ready() -> void:
	sub_viewport.hide()
	increment_store_item.connect(_increment_store_item)
	decrement_store_item.connect(_decrement_store_item)
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
	player.freeze_camera = false
	player.reticle.show()
	player.ui.show()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_cart_button_pressed() -> void:
	cart_items.visible = not cart_items.visible
	

func get_store_item_name(store_item:GlobalVar.StoreItem) -> StringName:
	if store_item == GlobalVar.StoreItem.None:
		return "Invalid Item"
	elif store_item == GlobalVar.StoreItem.RollingPin:
		return "Rolling Pin"
	elif store_item == GlobalVar.StoreItem.Dough:
		return "Dough"
	elif store_item == GlobalVar.StoreItem.Tomato:
		return "Tomato"
	elif store_item == GlobalVar.StoreItem.Cheese:
		return "Cheese"
	elif store_item == GlobalVar.StoreItem.Pepperoni:
		return "Pepperoni"
	elif store_item == GlobalVar.StoreItem.Mushroom:
		return "Mushroom"
	elif store_item == GlobalVar.StoreItem.PizzaBox:
		return "Pizza Box"
	else:
		return "Invalid Item"


func _on_purchase_button_pressed() -> void:
	if player.money - cart_total >= 0:
		player.update_money(-cart_total)
		cart_total = 0
		for label in cart_vbox.get_children():
			cart_vbox.remove_child(label)
		for store_item in order_items:
			if store_item.has("store_item"):
				update_store_item_to_cart_vbox(store_item.get("store_item"), 0)
		GlobalSignal.order_inventory_items.emit(order_items)
		order_items.clear()


func _on_mouse_entered() -> void:
	hover_audio.play()


func _increment_store_item(store_item: GlobalVar.StoreItem, price: int, quantity: int) -> void:
	cart_total += price
	update_store_item(store_item, quantity)
	update_store_item_to_cart_vbox(store_item, quantity)
	
func _decrement_store_item(store_item: GlobalVar.StoreItem, price: int, quantity: int) -> void:
	cart_total -= price
	update_store_item(store_item, quantity)
	update_store_item_to_cart_vbox(store_item, quantity)


func update_store_item(_store_item: GlobalVar.StoreItem, _quantity: int) -> void:
	var new_store_item_name = get_store_item_name(_store_item)
	var i = 0
	for store_item in order_items:
		if store_item.has("store_item"):
			var existing_store_item_name = get_store_item_name(store_item.get("store_item"))
			if existing_store_item_name == new_store_item_name:
				if store_item.has("quantity"):
					if _quantity == 0:
						order_items.remove_at(i)
					else:
						store_item.set("quantity", _quantity)
					return
		i += 1
	var new_dict: Dictionary = {
		"store_item": _store_item,
		"quantity": _quantity
	}
	order_items.append(new_dict)
	

		
func update_store_item_to_cart_vbox(_store_item: GlobalVar.StoreItem, _quantity: int) -> void:
	var new_store_item_name = get_store_item_name(_store_item)
	if cart_vbox.get_child_count() > 0:
		for store_item_label:Label in cart_vbox.get_children():
			var text = store_item_label.text
			var slice = text.get_slice(" x ", 0)
			if slice:
				if slice == new_store_item_name:
					if _quantity == 0:
						store_item_label.queue_free()
					else:
						store_item_label.text = slice + " x " + str(_quantity)
					return
	if _quantity == 0:
		return
	var new_label : Label = Label.new()
	new_label.text = new_store_item_name + " x " + str(_quantity)
	cart_vbox.add_child(new_label)
