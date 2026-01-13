extends Marker3D

@export var area: Area3D
@export var area_col: CollisionShape3D
@export var drive_thru_menu: DriveThruMenu
@export var drive_thru_timer: Timer
@export var dialogue_box: DialogueBox
@export var customer_collider: CollisionShape3D
@export var drive_thru_customer: DriveThruCustomer

var food_item: Item

func _on_area_3d_body_entered(body: Node3D) -> void:
	var obj = body.get_parent()
	if obj.is_in_group("items") and obj.has_meta("food_id") and drive_thru_menu.food_id != -1:
		var money: int
		if obj.get_meta("food_id") == drive_thru_menu.food_id:
			money = randi_range(6,10)
			dialogue_box.text = dialogue_box.get_good_order_delivered_text()
		else:
			money = randi_range(1,3)
			dialogue_box.text = dialogue_box.get_bad_order_delivered_text()
		dialogue_box.show()
		food_item = obj as Item
		food_item.disabled = true
		food_item.shrink_and_free(money)
		GlobalSignal.remove_order_from_list.emit(drive_thru_menu.table_id)
		GlobalSignal.check_restaurant_food.emit(obj.get_meta("food_id"))
		area_col.set_deferred("disabled", true)
		await get_tree().create_timer(2).timeout
		drive_thru_menu.hide()
		customer_collider.set_deferred("disabled", true)
		drive_thru_timer.wait_time = randf_range(15,60)
		drive_thru_timer.start()


func _on_drive_thru_timer_timeout() -> void:
	drive_thru_menu.show()
	area_col.set_deferred("disabled", false)
	customer_collider.set_deferred("disabled", false)
	drive_thru_customer.pointer.show()
