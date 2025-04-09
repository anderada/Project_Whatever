extends Node

@onready var ice: AudioStreamPlayer = $"Ice/Ice Looping"
@onready var pillar_1: AudioStreamPlayer = $"Pillar/Pillar 1"
@onready var pillar_2: AudioStreamPlayer = $"Pillar/Pillar 2"
@onready var pillar_3: AudioStreamPlayer = $"Pillar/Pillar 3"
@onready var pillar_4: AudioStreamPlayer = $"Pillar/Pillar 4"
@onready var walk_1: AudioStreamPlayer = $"Wood/Walk 1"
@onready var walk_2: AudioStreamPlayer = $"Wood/Walk 2"
@onready var walk_3: AudioStreamPlayer = $"Wood/Walk 3"
@onready var walk_4: AudioStreamPlayer = $"Wood/Walk 4"
@onready var walk_5: AudioStreamPlayer = $"Wood/Walk 5"
@onready var walk_6: AudioStreamPlayer = $"Wood/Walk 6"
@onready var walk_7: AudioStreamPlayer = $"Wood/Walk 7"
@onready var walk_8: AudioStreamPlayer = $"Wood/Walk 8"
@onready var lever: AudioStreamPlayer = $"Lever"
@onready var lamp: AudioStreamPlayer = $"Lamp"
@onready var door: AudioStreamPlayer = $"Door"
@onready var melt: AudioStreamPlayer = $"Melt"

var timeSinceLastSound : float = 0
@export var minimumTimeBetweenIceSounds : float = 0.4

func _process(delta: float) -> void:
	timeSinceLastSound+= delta

func startIce() -> void:
	ice.play()

func stopIce() -> void:
	ice.stop()
	
func icePlaying() -> bool:
	return ice.playing

func playSound(type : int) -> void:
	if(type == 8):
		var dice : int = randi_range(1,4)
		match dice:
			1:
				pillar_1.play()
			2:
				pillar_2.play()
			3:
				pillar_3.play()
			4:
				pillar_4.play()
	elif(type == 99):
		door.play()
	elif(type == 98):
		lever.play()
	elif(type == 97):
		melt.play()
	elif(type == 96):
		lamp.play()
	else:
		var dice : int = randi_range(1,8)
		match dice:
			1:
				walk_1.play()
			2:
				walk_2.play()
			3:
				walk_3.play()
			4:
				walk_4.play()
			5:
				walk_5.play()
			6:
				walk_6.play()
			7:
				walk_7.play()
			8:
				walk_8.play()
