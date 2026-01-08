extends Control

@export var ammo_label: RichTextLabel
@export var hp_bar: TextureProgressBar
@export var damage_overlay: ColorRect
@export var money_label: RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func update_ammo(ammo_count:int, max_ammo:int) -> void:
	ammo_label.text = str(ammo_count) + " / " + str(max_ammo)


func update_hp(current:int, target:int) -> void:
	var tween = create_tween()
	tween.tween_method(_update_hp, current, target, 0.25)


func _update_hp(value:int) -> void:
	hp_bar.value = value


func take_damage() -> void:
	var tween = create_tween()
	tween.tween_method(_take_damage, Color(0.0, 0.0, 0.0, 0.0), Color(1.0, 0.0, 0.0, 0.733), 0.2)
	tween.tween_method(_take_damage, Color(1.0, 0.0, 0.0, 0.733), Color(0.0, 0.0, 0.0, 0.0), 0.2)
	
	
func _take_damage(color: Color) -> void:
	damage_overlay.color = color


func update_money(_money:int) -> void:
	money_label.text = "$" + str(_money)
