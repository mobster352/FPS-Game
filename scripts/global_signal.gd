extends Node

## Adds the order to the monitor using the passed in [param table_id] and [param food_id].
@warning_ignore("unused_signal")
signal add_order(table_id:int, food_id: int)

## Gets the order from a given [param table_id].
@warning_ignore("unused_signal")
signal remove_order_from_list(table_id:int)

@warning_ignore("unused_signal")
signal table_empty(table_id:int)
