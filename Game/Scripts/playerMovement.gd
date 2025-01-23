extends Node3D

@export var moveTime : float
@export var moveCurve : Curve
@export var rotationTime : float
@export var rotationCurve : Curve
var forward : Vector2
var nextSpace : Vector2
var targetPosition : Vector3
var previousPosition : Vector3
var targetRotation : float = 0
var previousRotation : float = 0
var moveClock : float = 0
var rotationClock : float = 0
var lastMove : Vector2
var playerInput = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	targetPosition = position
	previousPosition = position
	targetRotation = rotation_degrees.y
	previousRotation = rotation_degrees.y

func _input(event):
	if event is InputEventKey:
		#turn left
		if event.keycode == KEY_A:
			playerInput.y = -1
		#turn right
		if event.keycode == KEY_D:
			playerInput.y = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#get forward vector for rotation
	forward = Vector2(roundf(position.x), roundf(position.z))
	nextSpace = Vector2(0,0);
	
	if(rotation_degrees.y > 360):
		rotation_degrees = Vector3(0,rotation_degrees.y -360,0)
	if(rotation_degrees.y < 0):
		rotation_degrees = Vector3(0,rotation_degrees.y +360,0)
	
	var nearest90 : int = roundf(rotation_degrees.y / 90) * 90
	
	match nearest90:
		0,360:
			forward.y += 1
			nextSpace.y = 1
		90:
			forward.x += 1
			nextSpace.x = 1
		180:
			forward.y -= 1
			nextSpace.y = -1
		270,-90:
			forward.x -= 1
			nextSpace.x = -1
	
	#take time off clocks
	moveClock -= delta
	rotationClock -= delta
	
	#get player input
	#forward
	if Input.is_key_pressed(KEY_W):
		playerInput.x = 1
	#backwards
	if Input.is_key_pressed(KEY_S):
		playerInput.x = -1
	
		
	#set target position and rotation
	#forward
	if(playerInput.x == 1 && moveClock <= 0):
		previousPosition = position
		targetPosition = position
		targetPosition.x += nextSpace.x
		targetPosition.z += nextSpace.y
		moveClock = moveTime
		lastMove = nextSpace
	#backwards
	if(playerInput.x == -1 && moveClock <= 0):
		previousPosition = position
		targetPosition = position
		targetPosition.x -= nextSpace.x
		targetPosition.z -= nextSpace.y
		moveClock = moveTime
		lastMove = -nextSpace
	#turn right
	if(playerInput.y == 1 && rotationClock <= 0):
		previousRotation = rotation_degrees.y
		targetRotation = rotation_degrees.y + 90
		rotationClock = rotationTime
	#turn left
	if(playerInput.y == -1 && rotationClock <= 0):
		previousRotation = rotation_degrees.y
		targetRotation = rotation_degrees.y - 90
		rotationClock = rotationTime
	targetRotation = round(targetRotation / 90) * 90
	
	#check collision
	if(targetPosition != previousPosition):
		pass
	
	#move player
	if(moveClock >= 0):
		position = Vector3(moveCurve.sample((moveTime - moveClock)/moveTime) * (previousPosition - targetPosition) + previousPosition)
	#make sure player is at centre of tile when stopped
	elif(moveClock >= -0.1):
		position = round(position)

	#print("_____________________")
	#print(previousRotation)
	#print(rotation)
	#print(targetRotation)

	#rotate player
	if(rotationClock >= 0):
		rotation_degrees = Vector3(0,rotationCurve.sample((rotationTime - rotationClock)/rotationTime) * (previousRotation - targetRotation) + previousRotation,0)
	elif(rotationClock >= -0.1):
		pass
		rotation_degrees = Vector3(0,round(rotation_degrees.y / 90) * 90,0)
		
	#reset input
	playerInput = Vector2(0,0)
