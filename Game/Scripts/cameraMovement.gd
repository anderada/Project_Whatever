extends Camera3D

@export var horizontalDegrees : float = 10
@export var verticalDegrees : float = 40
var mousePos
var previousMousePos
var mouseStillTime = 0 
@export var hideMouseTime : float = 2
@export var cameraShake : Curve
@export var cameraShakeIntensity : float
var shakeClock = 0
var shakeItteration = 0
@export var shakeTime : float

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
	rotation_degrees = Vector3(clampf(rotation_degrees.x, -verticalDegrees, verticalDegrees), clampf(rotation_degrees.y, -horizontalDegrees, horizontalDegrees), 0)
	
	shakeClock -= delta
	shakeItteration -= delta
	if(shakeClock >= 0):
		if(shakeItteration <=0):
			shakeItteration = min(shakeTime, shakeClock)
		position = Vector3(0, 1 + cameraShake.sample((shakeTime - shakeItteration)/shakeTime) * cameraShakeIntensity ,0)

func _on_player_start_shake(frequency: float, ammount: int) -> void:
	shakeTime = frequency
	shakeClock = frequency * ammount
	shakeItteration = frequency
