extends GridMap

signal pillarsInstanced
signal updateOffset

@export_group("Lever Settings")
@export var moveDistance : Vector3
@export var moveCurve : Curve
@export var moveTime : float
var up : bool = false
var downPosition : Vector3
var upPosition : Vector3
var moveClock : float = 0
var targetPosition : Vector3
var previousPosition : Vector3

@export_group("Tileset Settings")
@export var pillarIndex : int = 8
@export var hiddenPillarIndex : int = 9
@export var pillarPrefab : PackedScene
@export var pillarDownPoint : float = -0.96
@export var lampIndex : int = 19
@export var lampPrefab : PackedScene
var pillars : Array


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	downPosition = position
	upPosition = downPosition + moveDistance
	instancePillars()

func _process(delta: float) -> void:
	moveClock -= delta
	if(moveClock >= 0):
		if (up && position != upPosition) || (!up && position != downPosition):
			position = Vector3(moveCurve.sample((moveTime - moveClock)/moveTime) * (targetPosition - previousPosition) + previousPosition)
	elif(moveClock >= -1):
		if up:
			position = upPosition
		else:
			position = downPosition
		updateOffset.emit(position, self.name)
		moveClock = -2

func instancePillars():
	var cells = get_used_cells()
	for cell in cells:
		if(get_cell_item(cell) == pillarIndex):
			set_cell_item(cell, hiddenPillarIndex)
			var pos = Vector3(cell)
			pos.y += pillarDownPoint + 0.5
			var pillar = pillarPrefab.instantiate()
			pillar.transform = pillar.transform.scaled(Vector3(0.5,0.5,0.5))
			pillar.transform.origin = pos
			add_child(pillar)
			pillars.append(pillar)
		if(get_cell_item(cell) == lampIndex):
			var pos = Vector3(cell)
			pos.y -= 1
			var lamp = lampPrefab.instantiate()
			var orient = get_cell_item_orientation(cell)
			lamp.transform = lamp.transform.scaled(Vector3(0.5,0.5,0.5))
			pos = Vector3(round(pos.x),round(pos.y),round(pos.z))
			lamp.transform.origin = pos
			var rot = 0
			match orient:
				0:
					rot = 1
				10:
					rot = 3
				16:
					rot = 2
				22:
					rot = 0
			lamp.rotation = Vector3(0,rot * (PI / 2),0)
			add_child(lamp)
	pillarsInstanced.emit(position, pillars, pillarDownPoint, self.name)

func move() -> void:
	up = !up
	moveClock = moveTime
	if up:
		targetPosition = upPosition
	else:
		targetPosition = downPosition
	previousPosition = position
