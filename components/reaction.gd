class_name Reaction
extends Label3D

@export var good_order:bool
var start_pos:Vector3

func _ready() -> void:
	start_pos = position

func _on_visibility_changed() -> void:
	if visible:
		var tween = create_tween()
		if good_order:
			tween.tween_property(self, "position:y", position.y + 0.5, 2.0)
			modulate = Color.GREEN
			text = "+ +"
		else:
			tween.tween_property(self, "position:y", position.y - 0.5, 2.0)
			modulate = Color.RED
			text = "- -"
		await tween.finished
		hide()
	else:
		position = start_pos
