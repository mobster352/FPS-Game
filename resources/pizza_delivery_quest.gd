class_name PizzaDeliveryQuest
extends QuestDecorator

var item:StringName
var room_number:int
var order:Food

func _init(quest: QuestResource, room_no:int, item_mesh_name:StringName, order_food:Food) -> void:
	super(quest)
	room_number = room_no
	item = item_mesh_name
	order = order_food
