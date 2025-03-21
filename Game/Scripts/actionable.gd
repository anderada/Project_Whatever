extends Area3D

@export var dialogue_resource: DialogueResource
@export var dialogue_last_sentence: DialogueResource
var triggered : bool = false
@export var dialogue_start: String = "start"

func action() -> void:
	if(triggered):
		Telemetry.log_event("", "Dialogue", dialogue_last_sentence.get_path())
		DialogueManager.show_dialogue_balloon(dialogue_last_sentence, dialogue_start)
	else:
		Telemetry.log_event("", "Dialogue", dialogue_resource.get_path())
		DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_start)
		triggered = true
