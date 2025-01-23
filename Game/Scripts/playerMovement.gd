extends Node3D

@export var moveTime : float
@export var walkCurve : Curve
@export var slideInCurve : Curve
@export var slideCurve : Curve
@export var slideOutCurve : Curve
@export var rotationTime : float
@export var rotationCurve : Curve
@export var mazeRef : GridMap
var moveCurve : Curve
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
var sliding = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	targetPosition = position
	previousPosition = position
	targetRotation = rotation_degrees.y
	previousRotation = rotation_degrees.y
	moveCurve = walkCurve

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#get forward vector for rotation
	nextSpace = Vector2(0,0);
	
	if(rotation_degrees.y > 360):
		rotation_degrees = Vector3(0,rotation_degrees.y -360,0)
	if(rotation_degrees.y < 0):
		rotation_degrees = Vector3(0,rotation_degrees.y +360,0)
	var nearest90 : int = roundf(rotation_degrees.y / 90) * 90
	match nearest90:
		0,360:
			nextSpace.y = -1
		90:
			nextSpace.x = -1
		180:
			nextSpace.y = 1
		270,-90:
			nextSpace.x = 1
	
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
	#right
	if Input.is_key_pressed(KEY_D):
		playerInput.y = 1
	#left
	if Input.is_key_pressed(KEY_A):
		playerInput.y = -1
	
		
	#set target position and rotation
	#forward
	if(playerInput.x == 1 && moveClock <= 0 && !sliding):
		previousPosition = position
		targetPosition = position
		targetPosition.x += nextSpace.x
		targetPosition.z += nextSpace.y
		moveClock = moveTime
		lastMove = nextSpace
		setMoveCurve()
	#backwards
	if(playerInput.x == -1 && moveClock <= 0 && !sliding):
		previousPosition = position
		targetPosition = position
		targetPosition.x -= nextSpace.x
		targetPosition.z -= nextSpace.y
		moveClock = moveTime
		lastMove = -nextSpace
		setMoveCurve()
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
		#check head collision
		var headPosition = targetPosition
		headPosition.y += 1
		var blockPos = mazeRef.local_to_map(headPosition)
		var block = mazeRef.get_cell_item(blockPos)
		if(block != -1 && block != 3):
			stopPlayer()
		if(block == 3):
			targetPosition.x += lastMove.x
			targetPosition.y += 1
			targetPosition.z += lastMove.y
	
		#check feet collision
		blockPos = mazeRef.local_to_map(targetPosition)
		block = mazeRef.get_cell_item(blockPos)
		if(block == -1):
			stopPlayer()
		if(block == 3):
			targetPosition.x += lastMove.x
			targetPosition.y -= 1
			targetPosition.z += lastMove.y
	
	#move player
	if(moveClock >= 0):
		position = Vector3(moveCurve.sample((moveTime - moveClock)/moveTime) * (targetPosition - previousPosition) + previousPosition)
	#make sure player is at centre of tile when stopped
	elif(moveClock >= -0.5):
		moveClock = -1
		stopPlayer()
		#check ice
		var blockPos = mazeRef.local_to_map(position)
		var block = mazeRef.get_cell_item(blockPos)
		if(block == 1):
			targetPosition.x += lastMove.x
			targetPosition.z += lastMove.y
			moveClock = moveTime
			sliding = true
			setMoveCurve()


	#rotate player
	if(rotationClock >= 0):
		rotation_degrees = Vector3(0,rotationCurve.sample((rotationTime - rotationClock)/rotationTime) * (previousRotation - targetRotation) + previousRotation,0)
	elif(rotationClock >= -0.5):
		rotationClock = -1
		rotation_degrees = Vector3(0,round(rotation_degrees.y / 90) * 90,0)
		
	#reset input
	playerInput = Vector2(0,0)
	
func stopPlayer() -> void:
	position = round(position)
	targetPosition = position
	previousPosition = position
	sliding = false
	moveClock = -1

func setMoveCurve() -> void:
	var blockPos = mazeRef.local_to_map(position)
	var blockAtFeet = mazeRef.get_cell_item(blockPos)
	blockPos = mazeRef.local_to_map(targetPosition)
	var blockInFront = mazeRef.get_cell_item(blockPos)
	print(blockAtFeet)
	print(blockInFront)
	if(blockAtFeet != 1 && blockInFront == 1):
		moveCurve = slideInCurve
	if(blockAtFeet == 1 && blockInFront == 1):
		moveCurve = slideCurve
	if(blockAtFeet == 1 && blockInFront != 1):
		moveCurve = slideOutCurve
