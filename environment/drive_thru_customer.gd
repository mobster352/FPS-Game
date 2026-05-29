extends Interactable
class_name DriveThruCustomer

@export var drive_thru_menu: DriveThruMenu
#@export var dialogue_box: DialogueBox
@export var pointer: Node3D
#@export var area_col: CollisionShape3D
#@export var customer_collider: CollisionShape3D
@export var timer:Timer
@export var car_path:PathFollow3D
@export var drive_thru_path:PathFollow3D
@export var return_car_path:PathFollow3D
@export var drive_thru_spawn:DriveThruSpawn
@export var level:Level

@onready var reaction: Reaction = %Reaction

var in_range := false
var has_order := false
var is_store_open: bool = false

var food_item: Item

func _ready() -> void:
	GlobalSignal.pickup_food.connect(_pickup_food)
	GlobalSignal.drop_food.connect(_drop_food)
	GlobalSignal.open_store.connect(_open_store)
	%car_taxi_edited.car_path = car_path
	%car_taxi_edited.drive_thru_path = drive_thru_path
	%car_taxi_edited.return_car_path = return_car_path
	%car_taxi_edited.current_path = car_path
	drive_thru_spawn.drive_thru_menu = drive_thru_menu
	%car_taxi_edited.level = level

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = true
	else:
		var obj = body.get_parent()
		if obj.is_in_group("items") and obj.has_meta("food_id") and drive_thru_menu.food_id != -1:
			var money: int
			if obj is PizzaBox:
				if obj.get_meta("food_id") == drive_thru_menu.food_id:
					money = randi_range(10,15)
					reaction.good_order = true
					GlobalSignal.add_xp.emit(10)
				else:
					money = randi_range(1,3)
					reaction.good_order = false
				reaction.show()
				food_item = obj as Item
				food_item.disabled = true
				food_item.shrink_and_free(money, 0.5)
				GlobalSignal.remove_order_from_list.emit(drive_thru_menu.table_id)
				GlobalSignal.check_restaurant_food.emit(obj.get_meta("food_id"))
				#area_col.set_deferred("disabled", true)
				await get_tree().create_timer(2).timeout
				#dialogue_box.hide()
				#customer_collider.set_deferred("disabled", true)
				timer.wait_time = randf_range(15,60)
				timer.start()
				%car_taxi_edited.leave_drive_thru()
				has_order = false


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_range = false


func _on_drive_thru_menu_visibility_changed() -> void:
	in_range = false
	has_order = false


func _pickup_food(food_id:int) -> void:
	if drive_thru_menu.food_id == food_id:
		pointer.show()

func _drop_food(food_id:int) -> void:
	if drive_thru_menu.food_id == food_id:
		pointer.hide()


func can_interact(_player: Player) -> bool:
	if in_range and drive_thru_menu.visible and not %car_taxi_edited.is_moving and is_store_open:
		_player.inputs_ui.update_actions.emit(_player.inputs_ui.InputAction.Interact, _player.has_held_object())
	return in_range
	
func interact(_player: Player) -> void:
	if not has_order and drive_thru_menu.visible and not %car_taxi_edited.is_moving and is_store_open:
		var random_food = GlobalVar.get_random_food_by_level_for_drive_thru(_player.level)
		GlobalSignal.add_order.emit(0, random_food)
		GlobalSignal.check_restaurant_food.emit(random_food)
		pointer.hide()
		has_order = true
		#match random_food:
			#GlobalVar.PIZZA_TYPE.CHEESE_PIE:
				#dialogue_box.dialogue_id = &"CHEESE_PIZZA_DT"
			#GlobalVar.PIZZA_TYPE.PEPPERONI_PIE:
				#dialogue_box.dialogue_id = &"PEPPERONI_PIZZA_DT"
			#GlobalVar.PIZZA_TYPE.MUSHROOM_PIE:
				#dialogue_box.dialogue_id = &"MUSHROOM_PIZZA_DT"
		#dialogue_box.show()
	
func reticle_color() -> Color:
	return RETICLE_GREEN

func interact2(_player: Player) -> void:
	if _player.has_held_object():
		if _player.item_slot.get_child_count() > 0:
			_player.drop_item()


func _open_store() -> void:
	is_store_open = true
