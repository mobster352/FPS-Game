extends MarginContainer

@export var title: StringName
@onready var title_label: RichTextLabel = $TextureRect/RichTextLabel

func _ready() -> void:
	title_label.text = title
