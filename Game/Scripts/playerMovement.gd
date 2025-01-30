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
var goingUpStairs = false
var directionFacing = 0
var directionMoving = 0

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
	getNextSpace()
	
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
	if(playerInput.x == 1 && moveClock <= -1 && !sliding):
		previousPosition = position
		targetPosition = position
		targetPosition.x += nextSpace.x
		targetPosition.z += nextSpace.y
		moveClock = moveTime
		lastMove = nextSpace
		directionMoving = directionFacing
		setMoveCurve()
		checkCollision()
	#backwards
	if(playerInput.x == -1 && moveClock <= -1 && !sliding):
		previousPosition = position
		targetPosition = position
		targetPosition.x -= nextSpace.x
		targetPosition.z -= nextSpace.y
		moveClock = moveTime
		lastMove = -nextSpace
		directionMoving = directionFacing + 2
		directionMoving = directionMoving - 4 if directionMoving > 3 else directionMoving
		setMoveCurve()
		checkCollision()
	#turn right
	if(playerInput.y == 1 && rotationClock <= -1):
		previousRotation = rotation_degrees.y
		targetRotation = rotation_degrees.y + 90
		rotationClock = rotationTime
		directionFacing += 1
		directionFacing = 0 if directionFacing == 4 else directionFacing
		directionFacing = 3 if directionFacing == -1 else directionFacing
	#turn left
	if(playerInput.y == -1 && rotationClock <= -1):
		previousRotation = rotation_degrees.y
		targetRotation = rotation_degrees.y - 90
		rotationClock = rotationTime
		directionFacing -= 1
		directionFacing = 0 if directionFacing == 4 else directionFacing
		directionFacing = 3 if directionFacing == -1 else directionFacing
	targetRotation = round(targetRotation / 90) * 90
	targetPosition = round(targetPosition)
	
	#move player
	if(moveClock >= 0):
		#take longer to go up stairs
		if(goingUpStairs):
			if(position.distance_to(targetPosition) < 0.05):
				position = targetPosition
			else:
				position = Vector3(moveCurve.sample((moveTime * 2) - moveClock)/(moveTime * 2) * (targetPosition - previousPosition) + previousPosition)
		else:
			position = Vector3(moveCurve.sample((moveTime - moveClock)/moveTime) * (targetPosition - previousPosition) + previousPosition)
		
	#make sure player is at centre of tile when stopped
	elif(moveClock >= -0.5):
		moveClock = -1
		stopPlayer(false)
		#check ice
		var blockPos = mazeRef.local_to_map(position)
		var block = mazeRef.get_cell_item(blockPos)
		if(block == 1):
			targetPosition.x += lastMove.x
			targetPosition.z += lastMove.y
			moveClock = moveTime
			sliding = true
			setMoveCurve()
			checkCollision()


	#rotate player
	if(rotationClock >= 0):
		rotation_degrees = Vector3(0,rotationCurve.sample((rotationTime - rotationClock)/rotationTime) * (previousRotation - targetRotation) + previousRotation,0)
	elif(rotationClock >= -0.5):
		rotationClock = -1
		rotation_degrees = Vector3(0,round(rotation_degrees.y / 90) * 90,0)
		targetRotation = rotation_degrees.y
		
	#reset input
	playerInput = Vector2(0,0)
	
func stopPlayer(collided : bool) -> void:
	if(!collided):
		position = targetPosition
	position = round(position)
	targetPosition = position
	previousPosition = position
	sliding = false
	goingUpStairs = false
	moveClock = -1
	%Camera3D.startShake(0, 0)

func startStairs(offset : int) -> void:
	targetPosition.x += lastMove.x
	targetPosition.y += offset
	targetPosition.z += lastMove.y
	moveClock = moveTime * 2
	goingUpStairs = true
	%Camera3D.startShake(moveTime/2, 4)
	checkCollision()

func setMoveCurve() -> void:
	var blockPos = mazeRef.local_to_map(position)
	var blockAtFeet = mazeRef.get_cell_item(blockPos)
	blockPos = mazeRef.local_to_map(targetPosition)
	var blockInFront = mazeRef.get_cell_item(blockPos)
	if(blockAtFeet != 1 && blockInFront == 1):
		moveCurve = slideInCurve
	elif(blockAtFeet == 1 && blockInFront == 1):
		moveCurve = slideCurve
	elif(blockAtFeet == 1 && blockInFront != 1):
		moveCurve = slideOutCurve
	else:
		moveCurve = walkCurve
		%Camera3D.startShake(moveTime, 1)
	
func checkCollision() -> void:
	#check head collision
	var headPosition = targetPosition
	headPosition.y += 1
	var blockPos = mazeRef.local_to_map(headPosition)
	var block = mazeRef.get_cell_item(blockPos)
	if(block != -1 && block != 3 && !(block == 4 && abs(directionMoving - directionFacing) == 2)):
		stopPlayer(true)
	if(block == 3):
		startStairs(1)
	
	#check feet collision
	blockPos = mazeRef.local_to_map(targetPosition)
	block = mazeRef.get_cell_item(blockPos)
	if(block == -1):
		stopPlayer(true)
	if(block == 3):
		startStairs(-1)

func getNextSpace() -> void:
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
