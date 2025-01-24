extends Camera3D

@export var horizontalDegrees : float = 10
@export var verticalDegrees : float = 40
var mousePos
var previousMousePos
var mouseStillTime = 0 
@export var hideMouseTime : float = 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#get mouse position
	previousMousePos = mousePos
	mousePos = get_viewport().get_mouse_position()
	
	
	if(mousePos == previousMousePos):
		mouseStillTime += delta
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		mouseStillTime = 0
	
	if(mouseStillTime >= hideMouseTime):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	#rotate camera
	rotation_degrees = Vector3(-((mousePos.y - (get_viewport().size.y / 2))) * verticalDegrees / 360,-((mousePos.x - (get_viewport().size.x / 2))) * horizontalDegrees / 360,0)
