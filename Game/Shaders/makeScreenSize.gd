extends MeshInstance2D

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	var screensize = get_viewport_rect().size
	mesh.size = screensize
	mesh.set_center_offset(Vector3((screensize.x / 2), (screensize.y / 2), 1))
