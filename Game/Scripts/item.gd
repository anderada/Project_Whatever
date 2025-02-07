extends Node3D

func action() -> void:
	#play pick up animation
	#be collected
	get_parent_node_3d().hide()
