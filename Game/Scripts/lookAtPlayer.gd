extends Node3D

@export var offset : float = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#if(%Player != null):
		#look_at(%Player.global_position)
		#rotation_degrees.x = 0
		#rotation_degrees.y += offset
		#rotation_degrees.z = 0
