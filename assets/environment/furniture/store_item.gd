extends Panel

@export var computer: Computer
@export var text: StringName
@export var texture: Texture2D
@export var store_item: GlobalVar.StoreItem
@export var price: int

@export var item_name: Label
@export var item_icon: TextureRect
@export var background: ColorRect
@export var item_price: Label
@export var hover_audio: AudioStreamPlayer

@export var increment_item_button: TextureButton
@export var decrement_item_button: TextureButton
@export var quantity_label: Label

const normal_color = Color(0.282, 0.282, 0.282, 1.0)
const hover_color = Color(0.209, 0.209, 0.209, 1.0)

var quantity := 0:
	set(value):
		quantity = value
		quantity_label.text = str(quantity)

enum ButtonState {
	NotSelected,
	Selected
}

var button_state: ButtonState = ButtonState.NotSelected

func _ready() -> void:
	item_name.text = text
	item_icon.texture = texture
	item_price.text = "$" + str(price)
	GlobalSignal.order_inventory_items.connect(_order_inventory_items)


func _on_select_item_button_mouse_entered() -> void:
	hover_audio.play()


func _on_increment_item_pressed() -> void:
	if quantity == 9:
		return
	else:
		quantity += 1
	computer.increment_store_item.emit(store_item, price, quantity)


func _on_decrement_item_pressed() -> void:
	if quantity == 0:
		return
	else:
		quantity -= 1
	computer.decrement_store_item.emit(store_item, price, quantity)
	
func _order_inventory_items(_store_items: Array[Dictionary]) -> void:
	quantity = 0
