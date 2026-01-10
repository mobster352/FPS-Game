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
