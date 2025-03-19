extends Node3D

signal start_Stopwatch

var triggered : bool = false
@export var logMessage = ""
var stopwatch : float = 0
var counting : bool = false

func _process(delta: float) -> void:
	if(triggered):
		return
	if(counting):
		stopwatch += delta
	if(abs(%Player.position.distance_to(position)) < 1):
		Telemetry.log_event("", logMessage, stopwatch if stopwatch != 0 else "")
		triggered = true
		emit_signal("start_Stopwatch")

func startStopwatch():
	stopwatch = 0
	counting = true
