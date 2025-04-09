extends Node3D

signal trigger

@export var animator : AnimationTree
var triggered : bool = false

func _process(_delta: float) -> void:
	if(triggered):
		return
	if(abs(%Player.position.distance_to(position)) < 1):
		SoundManger.playSound(99)
		var state_machine = animator["parameters/playback"]
		if(state_machine != null):
			state_machine.travel("Open")
		else:
			print("no state machine")
		trigger.emit()
		triggered = true
		


func _on_trigger() -> void:
	triggered = true
