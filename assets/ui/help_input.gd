extends Control

@export var help_text:String
@export var help_button:String

func _ready() -> void:
	%HelpText.text = help_text
	%HelpButton.text = help_button
