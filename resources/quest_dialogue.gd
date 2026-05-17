class_name QuestDialogue
extends DialogueBase

@export var quest_id:StringName

func _init(dialogue:Dialogue, _quest_id:StringName) -> void:
	super(dialogue)
	quest_id = _quest_id
