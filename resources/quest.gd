class_name Quest
extends Resource

enum QuestStatus {
	None,
	NOT_STARTED,
	IN_PROGRESS,
	COMPLETE
}

enum QuestIds {
	OPEN_COMPUTER,
	BUY_INGREDIENTS,
	OPEN_PIZZERIA,
	SERVE_CUSTOMERS,
	CLOSE_PIZZERIA
}

const QUEST_TITLES = {
	QuestIds.OPEN_COMPUTER: "Open Computer",
	QuestIds.BUY_INGREDIENTS: "Buy Ingredients",
	QuestIds.OPEN_PIZZERIA: "Open Pizzeria",
	QuestIds.SERVE_CUSTOMERS: "Serve Customers",
	QuestIds.CLOSE_PIZZERIA: "Close Pizzeria"
}

@export var id:QuestIds
@export var description:String
#@export var status:QuestStatus
