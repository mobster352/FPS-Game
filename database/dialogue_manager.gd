extends Node

var dialogue_db:Array[DialogueResource]

func _ready() -> void:
	load_dialogue("res://resources/dialogue/")

func load_dialogue(path: String) -> void:
	var dir = ResourceLoader.list_directory(path)
	for ent_name in dir:
		if ent_name.ends_with(".tres"):
			var ent_path: String = path + "/" + ent_name
			var dialogue = load(ent_path)
			dialogue_db.append(dialogue)

func get_dialogue_by_id(dialogue_id:StringName, index:int) -> String:
	for dialogue_resource:DialogueResource in dialogue_db:
		if dialogue_resource.id == dialogue_id:
			if dialogue_resource.lines.has(index):
				var dialogue_line:DialogueLine = dialogue_resource.lines.get(index)
				if dialogue_line:
					return dialogue_line.text
			push_error("Dialogue index is invalid")
			break
	return ""
