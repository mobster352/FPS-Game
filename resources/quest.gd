class_name Quest
extends Resource

class QuestData:
	var id:int
	var name:String
	var objectives:Array[QuestObjective]
	
	func create_quest_data(_id:int) -> QuestData:
		id = _id
		name = QUEST_TITLES[_id]
		for obj_id in QUEST_OBJECTIVES[_id]:
			var quest_objective:QuestObjective = QuestObjective.new()
			objectives.append(quest_objective.create_quest_objective(obj_id))
		return self
		
class QuestObjective:
	var id:int
	var name:String
	var status:bool
	
	func create_quest_objective(_id:int) -> QuestObjective:
		id = _id
		name = QUEST_OBJECTIVES_TEXT[_id]
		status = false
		return self


enum QuestIds {
	#OPEN_COMPUTER,
	BUY_INGREDIENTS,
	MOVE_PRODUCTS,
	MAKE_PIZZA,
	PLACE_PIZZA,
	BUY_TABLE,
	CHANGE_STORE_NAME,
	OPEN_PIZZERIA,
	SERVE_CUSTOMERS,
	CLOSE_PIZZERIA
}

const QUEST_TITLES = {
	#QuestIds.OPEN_COMPUTER: "Open Computer",
	QuestIds.BUY_INGREDIENTS: "Buy Ingredients from Computer",
	QuestIds.MOVE_PRODUCTS: "Pick Up Products",
	QuestIds.MAKE_PIZZA: "Make your first Pizza",
	QuestIds.PLACE_PIZZA: "Refill Pizza Slices",
	QuestIds.BUY_TABLE: "Buy Table",
	QuestIds.CHANGE_STORE_NAME: "Change Store Name",
	QuestIds.OPEN_PIZZERIA: "Open Pizzeria",
	QuestIds.SERVE_CUSTOMERS: "Serve Customers",
	QuestIds.CLOSE_PIZZERIA: "Close Pizzeria"
}

enum QuestObjs {
	#CLICK_ON_COMPUTER,
	BUY_ROLLING_PIN,
	BUY_DOUGH,
	BUY_TOMATO,
	BUY_CHEESE,
	PICK_UP_PRODUCTS,
	PICK_UP_DOUGH,
	ROLL_DOUGH,
	ADD_TOMATO,
	ADD_CHEESE,
	PLACE_PIZZA_OVEN,
	REMOVE_PIZZA_OVEN,
	PLACE_PIZZA_COUNTER,
	OPEN_TABLET,
	BUY_TABLE,
	CHANGE_STORE_NAME,
	OPEN_PIZZERIA,
	SERVER_CUSTOMERS,
	CLOSE_PIZZERIA
}


const QUEST_OBJECTIVES_TEXT = {
	#QuestObjs.CLICK_ON_COMPUTER: "Click on Computer",
	QuestObjs.BUY_ROLLING_PIN: "Buy Rolling Pin",
	QuestObjs.BUY_DOUGH: "Buy Dough",
	QuestObjs.BUY_TOMATO: "Buy Tomato",
	QuestObjs.BUY_CHEESE: "Buy Cheese",
	QuestObjs.PICK_UP_PRODUCTS: "Pick Up Products",
	QuestObjs.PICK_UP_DOUGH: "Pick Up a dough ball",
	QuestObjs.ROLL_DOUGH: "Roll out the dough ball into a pizza base",
	QuestObjs.ADD_TOMATO: "Add a tomato to the pizza",
	QuestObjs.ADD_CHEESE: "Add cheese to the pizza",
	QuestObjs.PLACE_PIZZA_OVEN: "Place pizza into the oven",
	QuestObjs.REMOVE_PIZZA_OVEN: "Remove pizza from the oven",
	QuestObjs.PLACE_PIZZA_COUNTER: "Place pizza on the counter",
	QuestObjs.OPEN_TABLET: "Open Tablet",
	QuestObjs.BUY_TABLE: "Buy Table",
	QuestObjs.CHANGE_STORE_NAME: "Click on the Store Sign",
	QuestObjs.OPEN_PIZZERIA: "Open Pizzeria",
	QuestObjs.SERVER_CUSTOMERS: "Serve Customers",
	QuestObjs.CLOSE_PIZZERIA: "Close Pizzeria"
}

const QUEST_OBJECTIVES = {
	#QuestIds.OPEN_COMPUTER: [
		#QuestObjs.CLICK_ON_COMPUTER
	#],
	QuestIds.BUY_INGREDIENTS: [
		QuestObjs.BUY_ROLLING_PIN,
		QuestObjs.BUY_DOUGH,
		QuestObjs.BUY_TOMATO,
		QuestObjs.BUY_CHEESE
	],
	QuestIds.MOVE_PRODUCTS: [
		QuestObjs.PICK_UP_PRODUCTS
	],
	QuestIds.MAKE_PIZZA: [
		QuestObjs.PICK_UP_DOUGH,
		QuestObjs.ROLL_DOUGH,
		QuestObjs.ADD_TOMATO,
		QuestObjs.ADD_CHEESE,
		QuestObjs.PLACE_PIZZA_OVEN,
		QuestObjs.REMOVE_PIZZA_OVEN
	],
	QuestIds.PLACE_PIZZA: [
		QuestObjs.PLACE_PIZZA_COUNTER
	],
	QuestIds.BUY_TABLE: [
		QuestObjs.OPEN_TABLET,
		QuestObjs.BUY_TABLE
	],
	QuestIds.CHANGE_STORE_NAME: [
		QuestObjs.CHANGE_STORE_NAME
	],
	QuestIds.OPEN_PIZZERIA: [
		QuestObjs.OPEN_PIZZERIA
	],
	QuestIds.SERVE_CUSTOMERS: [
		QuestObjs.SERVER_CUSTOMERS
	],
	QuestIds.CLOSE_PIZZERIA: [
		QuestObjs.CLOSE_PIZZERIA
	]
}


@export var id:QuestIds
