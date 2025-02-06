extends Node

var grid : GridMap
var player : Node3D
var pillars : Array
var pillarActives : Array
var pillarDefaults : Array
var pillarStates : Array
var pillarClocks : Array
var offset : Vector3
@export var animationTime : float = 0.2
@export var activateCurve : Curve 
@export var deactivateCurve : Curve 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid = get_parent()
	player = %Player

func _process(delta: float) -> void:
	var i = 0
	for clock in pillarClocks:
		clock -= delta
		pillarClocks[i] = clock
		if(clock >= 0):
			match pillarStates[i]:
				0:
					pillars[i].transform.origin = Vector3(deactivateCurve.sample((animationTime - clock)/animationTime) * (pillarDefaults[i] - pillarActives[i]) + pillarActives[i])
				1:
					pillars[i].transform.origin = Vector3(activateCurve.sample((animationTime - clock)/animationTime) * (pillarActives[i] - pillarDefaults[i]) + pillarDefaults[i])
		elif(pillarStates[i] == -1):
			pillarClocks[i] = animationTime
			pillarStates[i] = 0
		i += 1

func _on_player_activate_pillar(position: Vector3) -> void:
	var i = 0
	for pillar in pillars:
		if(pillarStates[i] == 0 && pillar.transform.origin.distance_to(position - offset) < 1):
			pillarClocks[i] = animationTime
			pillarStates[i] = 1
		elif(pillarStates[i] == -1 && pillar.transform.origin.distance_to(position - offset) < 1):
			pillarClocks[i] = 0
			pillarStates[i] = 1
		i += 1

func _on_player_deactivate_pillar() -> void:
	var i = 0
	for pillar in pillars:
		if(pillarStates[i] == 1 && pillarClocks[i] < 0):
			pillarStates[i] = -1
		i += 1


func _on_grid_map_pillars_instanced(mazeOffset : Vector3) -> void:
	pillars = grid.pillars
	offset = mazeOffset
	for pillar in pillars:
		var location = pillar.transform.origin
		pillarActives.append(Vector3(location.x, location.y - grid.pillarDownPoint, location.z))
		pillarDefaults.append(location)
		pillarStates.append(0)
		pillarClocks.append(0)
