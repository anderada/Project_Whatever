extends Actionable
@export var letterID:int
@export var letterPanel:Panel
@export var letter1:TextureRect
@export var letter2:TextureRect
@export var letter3:TextureRect
@export var letter4:TextureRect
@export var camera:Camera3D
@export var letterClose:Button

func action()->void:
	if(letterPanel.visible):
		return
	letterPanel.visible = true
	letterPanel.justOpened = true
	letterClose.visible = true
	letter1.visible = false
	letter2.visible = false
	letter3.visible = false
	letter4.visible = false
	match letterID:
		1:
			letter1.visible = true
		2:
			letter2.visible = true
		3:
			letter3.visible = true
		4:
			letter4.visible = true
	camera.lockCamera(true)
	
	InventoryData.collect_item(letterID)
