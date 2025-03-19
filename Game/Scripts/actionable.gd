extends Area3D

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

func action() -> void:
	Telemetry.log_event("", "Dialogue", dialogue_resource.get_path())
	DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_start)
