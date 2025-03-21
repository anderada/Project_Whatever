extends GridMap

signal pillarsInstanced

@export var pillarIndex : int = 4
@export var hiddenPillarIndex : int = 6
@export var pillarPrefab : PackedScene
@export var pillarDownPoint : float = -0.9
@export var lampIndex : int = 18
@export var lampPrefab : PackedScene
var pillars : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instancePillars()

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
			lamp.transform = lamp.transform.scaled(Vector3(0.5,0.5,0.5))
			lamp.transform.origin = pos
			add_child(lamp)
	pillarsInstanced.emit(position, pillars, pillarDownPoint)
