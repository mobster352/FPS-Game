class_name Cash
extends Node3D

enum CashDenom {
	ONE,
	FIVE,
	TEN,
	TWENTY,
	FIFTY
}

const cash_1 = preload("uid://dkwk5g43c4yoe")
const cash_5 = preload("uid://sr7mofog7xv1")
const cash_10 = preload("uid://byr851ffeqrcs")
const cash_20 = preload("uid://d02a0we1pu600")
const cash_50 = preload("uid://odlj4snushh2")

@export var cash_denom:CashDenom
@export var in_register:bool
@export var body:RigidBody3D

var cash_value:int

var cash_obj:Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match cash_denom:
		CashDenom.ONE:
			cash_value = 1
			if in_register:
				body.freeze = true
				%Label3D.text = "$1"
			cash_obj = cash_1.instantiate()
		CashDenom.FIVE:
			cash_value = 5
			if in_register:
				body.freeze = true
				%Label3D.text = "$5"
			cash_obj = cash_5.instantiate()
		CashDenom.TEN:
			cash_value = 10
			if in_register:
				body.freeze = true
				%Label3D.text = "$10"
			cash_obj = cash_10.instantiate()
		CashDenom.TWENTY:
			cash_value = 20
			if in_register:
				body.freeze = true
				%Label3D.text = "$20"
			cash_obj = cash_20.instantiate()
		CashDenom.FIFTY:
			cash_value = 50
			if in_register:
				body.freeze = true
				%Label3D.text = "$50"
			cash_obj = cash_50.instantiate()
	if cash_obj:
		body.add_child(cash_obj)
