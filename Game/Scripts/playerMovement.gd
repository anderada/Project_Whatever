extends Node3D

signal activatePillar(position: Vector3)
signal deactivatePillar()
signal startShake(frequency: float, ammount: int)

@export var moveTime : float
@export var walkCurve : Curve
@export var slideInCurve : Curve
@export var slideCurve : Curve
@export var slideOutCurve : Curve
@export var rotationTime : float
@export var rotationCurve : Curve

var moveCurve : Curve
var nextSpace : Vector2
var right : Vector2
var left : Vector2
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

@export var mazeMaps : Array

@export var iceIndex : int = 1
@export var stairIndex : int = 3
@export var pillarIndex : int = 6
@export var bridgeIndex : int = 5

@onready var actionable_finder: Area3D = $Direction/ActionableFinder

func _ready() -> void:
	targetPosition = position
	previousPosition = position
	targetRotation = rotation_degrees.y
	previousRotation = rotation_degrees.y
	moveCurve = walkCurve
	getNextSpace()
	Telemetry.set_section("Level 1")

func _process(delta: float) -> void:
	updateMovementClocks(delta)
	getPlayerInput()
	move()
	turn()
	resetPlayerInput()

func getBlock(location : Vector3) -> int:
	#return get_node(mazeMaps[0]).get_cell_item(location)
	for mapPath in mazeMaps:
		var map : GridMap = get_node(mapPath)
		var mazePosition = location - map.transform.origin
		mazePosition.y -= 0.5
		var block = map.get_cell_item(mazePosition)
		if(block >= 0):
			return block
	return -1

func updateMovementClocks(delta: float) -> void:
	#take time off clocks
	moveClock -= delta
	rotationClock -= delta

func getPlayerInput() -> void:
	#get player input
	#forward
	if Input.is_action_pressed("Forward"):
		playerInput.x = 1
	#backwards
	if Input.is_action_pressed("Backward"):
		playerInput.x = -1
	#right
	if Input.is_action_just_pressed("Right"):
		playerInput.y = 1
		Telemetry.log_event("","Turn","Right")
	#left
	if Input.is_action_just_pressed("Left"):
		playerInput.y = -1
		Telemetry.log_event("","Turn","Left")
	
		
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
		getNextSpace()
	#turn left
	if(playerInput.y == -1 && rotationClock <= -1):
		previousRotation = rotation_degrees.y
		targetRotation = rotation_degrees.y - 90
		rotationClock = rotationTime
		directionFacing -= 1
		directionFacing = 0 if directionFacing == 4 else directionFacing
		directionFacing = 3 if directionFacing == -1 else directionFacing
		getNextSpace()
	targetRotation = round(targetRotation / 90) * 90
	targetPosition = round(targetPosition)

func resetPlayerInput() -> void:
	playerInput = Vector2(0,0)

func move() -> void:
	
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
		var block = getBlock(position)
		if(block == iceIndex):
			targetPosition.x += lastMove.x
			targetPosition.z += lastMove.y
			moveClock = moveTime
			sliding = true
			setMoveCurve()
			checkCollision()

func turn() -> void:
	#rotate player
	if(rotationClock >= 0):
		rotation_degrees = Vector3(0,rotationCurve.sample((rotationTime - rotationClock)/rotationTime) * (previousRotation - targetRotation) + previousRotation,0)
	elif(rotationClock >= -0.5):
		rotationClock = -1
		rotation_degrees = Vector3(0,round(rotation_degrees.y / 90) * 90,0)
		targetRotation = rotation_degrees.y
		getNextSpace()
		checkPillars()

func stopPlayer(collided : bool) -> void:
	if(!collided):
		position = targetPosition
		SoundManger.playSound(getBlock(position))
		Telemetry.log_event("","Move",{x = position.x, y = position.y, z = position.z})
	position = round(position)
	targetPosition = position
	previousPosition = position
	sliding = false
	goingUpStairs = false
	moveClock = -1
	startShake.emit(0, 0)
	getNextSpace()
	checkPillars()

func startStairs(offset : int) -> void:
	targetPosition.x += lastMove.x
	targetPosition.y += offset
	targetPosition.z += lastMove.y
	moveClock = moveTime * 2
	goingUpStairs = true
	startShake.emit(moveTime/2, 4)
	checkCollision()

func setMoveCurve() -> void:
	var blockAtFeet = getBlock(position)
	var blockInFront = getBlock(targetPosition)
	if(blockAtFeet != iceIndex && blockInFront == iceIndex):
		moveCurve = slideInCurve
	elif(blockAtFeet == iceIndex && blockInFront == iceIndex):
		moveCurve = slideCurve
	elif(blockAtFeet == iceIndex && blockInFront != iceIndex):
		moveCurve = slideOutCurve
	else:
		moveCurve = walkCurve
		startShake.emit(moveTime, 1)

func checkCollision() -> void:
	#check head collision
	var headPosition = targetPosition
	headPosition.y += 1
	var block = getBlock(headPosition)
	if(block != -1 && block != stairIndex && block != bridgeIndex && !(block == pillarIndex && abs(directionMoving - directionFacing) > 0)):
		stopPlayer(true)
	if(block == stairIndex):
		startStairs(1)
	
	#check feet collision
	block = getBlock(targetPosition)
	if(block == -1 || block == pillarIndex):
		stopPlayer(true)
	if(block == stairIndex):
		startStairs(-1)

func getNextSpace() -> void:
	nextSpace = Vector2(0,0);
	right = Vector2(0,0);
	left = Vector2(0,0);

	match directionFacing:
		0:
			nextSpace.y = -1
			right.x = -1
			left.x = 1
		1:
			nextSpace.x = 1
			right.y = -1
			left.y = 1
		2:
			nextSpace.y = 1
			right.x = 1
			left.x = -1
		3:
			nextSpace.x = -1
			right.y = 1
			left.y = -1

func checkPillars() -> void:
	deactivatePillar.emit()
	var pos
	var block
	##check forward
	for i in range(1,4):
		pos = position
		pos += Vector3(nextSpace.x * i, 1, nextSpace.y * i)
		block = getBlock(pos)
		if(block == pillarIndex):
				activatePillar.emit(pos)
		
		pos = position + Vector3(left.x, 0, left.y)
		pos += Vector3(nextSpace.x * i, 1, nextSpace.y * i)
		block = getBlock(pos)
		if(block == pillarIndex):
				activatePillar.emit(pos)
				
		pos = position + Vector3(right.x, 0, right.y)
		pos += Vector3(nextSpace.x * i, 1, nextSpace.y * i)
		block = getBlock(pos)
		if(block == pillarIndex):
				activatePillar.emit(pos)
	"""check forward, below
	for i in range(0,4):
		pos = position
		pos += Vector3(nextSpace.x * i, 0, nextSpace.y * i)
		block = mazeRef.get_cell_item(pos)
		if(block == pillarIndex):
				activatePillar.emit(pos)
	"""
	"""check sides
	pos = position
	pos += Vector3(right.x, 1, right.y)
	block = mazeRef.get_cell_item(pos)
	if(block == pillarIndex):
			activatePillar.emit(pos)
	
	pos = position
	pos += Vector3(left.x, 1, left.y)
	block = mazeRef.get_cell_item(pos)
	if(block == pillarIndex):
			activatePillar.emit(pos)
	"""

@warning_ignore("unused_parameter")
func _on_actionable_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if (event is InputEventMouseButton):
		var actionables = actionable_finder.get_overlapping_areas()
		if (event.button_index == MOUSE_BUTTON_LEFT && event.pressed && actionables.size() > 0):
				actionables[0].action()
