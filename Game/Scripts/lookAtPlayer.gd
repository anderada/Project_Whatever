extends Node3D

@export var offset : float = 0
@export var lockPitch : bool = true

var player: Node3D
@export var playerPath = "/root/Test Scene3/Player"

func _ready() -> void:
	player = get_node(playerPath)
	if(player == null && %Player != null):
		player = %Player

@warning_ignore("unused_parameter")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(player != null && player.position != position):
		look_at(player.global_position)
		rotation_degrees.y += offset
		if(lockPitch):
			rotation_degrees.x = 0
			rotation_degrees.z = 0
		
