class_name CashRegister
extends Node3D

const drawer_closed_position = Vector3(0.18, 0.055, 0.0)
const drawer_open_position = Vector3(0.30, 0.055, 0.0)

@export var cashier_marker:Marker3D

var is_open:bool
var npc_dummy:NPC_Dummy
var change:int:
	set(value):
		change = value
		%ChangeValue.text = format_money(value)
var total:int = 0
var money_payed:int = 0
var player:Player
var in_range:bool = false

func _ready() -> void:
	%MarginContainer.hide()
	set_register_visibility(false)
	change = 0
	GlobalSignal.process_order.connect(_process_order)
	GlobalSignal.remove_order_from_register.connect(_remove_order_from_register)
	player = get_tree().get_first_node_in_group("player")


func _process(_delta: float) -> void:
	if is_open and player.is_cashier and change == 0 and %MarginContainer.visible:
		%ConfirmTransaction.show()
	else:
		%ConfirmTransaction.hide()
	if Input.is_action_just_pressed("complete_transaction") and is_open and player.is_cashier:
		if change == 0:
			_remove_order_from_register()
			GlobalSignal.process_payment.emit(npc_dummy)
			player.update_money(total)
			total = 0
	if not player.is_cashier:
		set_register_visibility(false)
		_clear_money()
		change = money_payed - total
		


func _clear_money() -> void:
	for child:Node3D in %CashSpawn.get_children():
		child.queue_free()


func _remove_order_from_register() -> void:
	_clear_money()
	change = -1000
	%MarginContainer.hide()
	%OrderValue.text = ""
	%ReceivedValue.text = ""
	%TotalValue.text = ""
	%ChangeValue.text = ""



func _process_order(_npc_dummy:NPC_Dummy, _money_payed:int, _total:int, random_food:int) -> void:
	_clear_money()
	
	total = _total
	money_payed = _money_payed
	change = money_payed - total
	
	%MarginContainer.show()
	
	var order_food:StringName = "Invalid Food"
	for food in GlobalVar.food_items:
		if random_food == food.food_id:
			order_food = food.food_name
			break
	
	%OrderValue.text = order_food
	%ReceivedValue.text = format_money(money_payed)
	%TotalValue.text = format_money(total)
	
	npc_dummy = _npc_dummy


func format_money(money:int) -> String:
	return "$" + str(money)

func set_register_visibility(_is_visible:bool) -> void:
	is_open = _is_visible
	if _is_visible:
		%cash_drawer.position = drawer_open_position
	else:
		%cash_drawer.position = drawer_closed_position

	%cash_1.visible = _is_visible
	%cash_5.visible = _is_visible
	%cash_10.visible = _is_visible
	%cash_20.visible = _is_visible
	%cash_50.visible = _is_visible


func update_change(cash_value:int, add:bool) -> void:
	if add:
		change += cash_value
		return
	else:
		change -= cash_value
	var cash_obj:Cash = preload("uid://cefdcjkgsta4f").instantiate()
	match cash_value:
		1:
			cash_obj.cash_denom = Cash.CashDenom.ONE
		5:
			cash_obj.cash_denom = Cash.CashDenom.FIVE
		10:
			cash_obj.cash_denom = Cash.CashDenom.TEN
		20:
			cash_obj.cash_denom = Cash.CashDenom.TWENTY
		50:
			cash_obj.cash_denom = Cash.CashDenom.FIFTY
	cash_obj.in_register = false
	cash_obj.scale = Vector3(1,1,1)
	cash_obj.position = %CashSpawn.position
	%CashSpawn.add_child(cash_obj)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false
