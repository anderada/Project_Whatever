extends Camera3D

@export var horizontalDegrees : float = 10
@export var verticalDegrees : float = 40

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#get mouse position
	var mousePos = get_viewport().get_mouse_position()
	
	#rotate camera
	rotation_degrees = Vector3(-((mousePos.y - (get_viewport().size.y / 2))) * verticalDegrees / 360,-((mousePos.x - (get_viewport().size.x / 2))) * horizontalDegrees / 360,0)
