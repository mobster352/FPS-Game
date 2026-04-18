extends Node

## Adds the order to the monitor using the passed in [param table_id] and [param food_id].
@warning_ignore("unused_signal")
signal add_order(table_id:int, food_id: int)

## Gets the order from a given [param table_id].
@warning_ignore("unused_signal")
signal remove_order_from_list(table_id:int)

@warning_ignore("unused_signal")
signal table_empty(table_id:int)

@warning_ignore("unused_signal")
signal get_open_table(npc_dummy:NPC_Dummy)

@warning_ignore("unused_signal")
signal assign_customer_to_table(table:Table, npc_dummy:NPC_Dummy)

@warning_ignore("unused_signal")
signal remove_customer(npc_dummy:NPC_Dummy)

@warning_ignore("unused_signal")
signal pickup_food(food_id:int)

@warning_ignore("unused_signal")
signal drop_food(food_id:int)

@warning_ignore("unused_signal")
signal init_restaurant(restaurant:Restaurant)

@warning_ignore("unused_signal")
signal check_restaurant_food(food_id:int)

@warning_ignore("unused_signal")
signal toggle_pointer_by_food(food_id:int, value:bool)

@warning_ignore("unused_signal")
signal toggle_pointer(meta: StringName, value: bool)

@warning_ignore("unused_signal")
signal toggle_pointer_ui()

@warning_ignore("unused_signal")
signal init_player(player: Player)

@warning_ignore("unused_signal")
signal order_inventory_items(store_items: Array[Dictionary])

@warning_ignore("unused_signal")
signal toggle_background_audio()

@warning_ignore("unused_signal")
signal add_table(table: Table)

@warning_ignore("unused_signal")
signal send_table_id(table: Table, table_id: int)

@warning_ignore("unused_signal")
signal remove_table(table: Table)

@warning_ignore("unused_signal")
signal init_player_mp(player: PlayerMP)

@warning_ignore("unused_signal")
signal remove_object_from_level(id:int)

@warning_ignore("unused_signal")
signal add_item_to_player(mesh_name:String, player_id:int)

@warning_ignore("unused_signal")
signal player_drop_item(mesh_name:String, item_position:Vector3, player_id:int)

@warning_ignore("unused_signal")
signal freeze_player_camera(freeze:bool)

@warning_ignore("unused_signal")
signal next_day(submit:bool)

@warning_ignore("unused_signal")
signal change_scene

@warning_ignore("unused_signal")
signal open_store

@warning_ignore("unused_signal")
signal close_store

@warning_ignore("unused_signal")
signal update_store_name(store_name:String, font_size:int)

@warning_ignore("unused_signal")
signal process_order(_npc_dummy:NPC_Dummy, money_payed:int, total:int, random_food:int)

@warning_ignore("unused_signal")
signal process_payment(_npc_dummy:NPC_Dummy)

@warning_ignore("unused_signal")
signal check_for_open_table

@warning_ignore("unused_signal")
signal update_money(money:int)

@warning_ignore("unused_signal")
signal update_money_floating_text(money:int)

@warning_ignore("unused_signal")
signal update_time(time:String, is_pm:bool)

@warning_ignore("unused_signal")
signal set_time_visibility(visible:bool)
