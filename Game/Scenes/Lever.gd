extends Area3D

@export var toMove : GridMap

func action() -> void:
	toMove.move()
