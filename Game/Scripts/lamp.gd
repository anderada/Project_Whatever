extends Node3D

@export var lamp : OmniLight3D
@export var playerPath = "/root/Test Scene3/Player"
var triggered : bool = false
var player: Node3D

func _ready() -> void:
	player = get_node(playerPath)
	if(player == null && %Player != null):
		player = %Player

func _process(delta: float) -> void:
	if(triggered):
		return
	if(abs(player.position.distance_to(position)) < 1):
		lamp.omni_range = 5
		triggered = true
