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
@export var select_item_button: TextureButton
@export var not_selected_texture: Texture2D
@export var selected_texture: Texture2D
@export var not_selected_hover_texture: Texture2D
@export var selected_hover_texture: Texture2D

const normal_color = Color(0.282, 0.282, 0.282, 1.0)
const hover_color = Color(0.209, 0.209, 0.209, 1.0)

enum ButtonState {
	NotSelected,
	Selected
}

var button_state: ButtonState = ButtonState.NotSelected

func _ready() -> void:
	item_name.text = text
	item_icon.texture = texture
	item_price.text = "$" + str(price)
	computer.remove_store_item.connect(_remove_store_item)

func _on_color_rect_mouse_entered() -> void:
	#background.color = hover_color
	pass


func _on_color_rect_mouse_exited() -> void:
	#background.color = normal_color
	pass


func _on_select_item_button_pressed() -> void:
	if button_state == ButtonState.NotSelected:
		button_state = ButtonState.Selected
		select_item_button.texture_normal = selected_texture
		select_item_button.texture_hover = selected_hover_texture
		computer.select_store_item.emit(store_item, price, true)
	else:
		button_state = ButtonState.NotSelected
		select_item_button.texture_normal = not_selected_texture
		select_item_button.texture_hover = not_selected_hover_texture
		computer.select_store_item.emit(store_item, price, false)

func _remove_store_item(_store_item: GlobalVar.StoreItem) -> void:
	if _store_item == store_item:
		button_state = ButtonState.NotSelected
		select_item_button.texture_normal = not_selected_texture
		select_item_button.texture_hover = not_selected_hover_texture
