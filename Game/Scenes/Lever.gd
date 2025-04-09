extends Area3D

@export var toMove : GridMap
@export var greenLight : OmniLight3D
@export var redLight : OmniLight3D
@export var animator : AnimationPlayer
var up : bool = true

func action() -> void:
	toMove.move()
	SoundManger.playSound(98)
	up = !up
	if(!up):
		animator.play("LeverAction")
		greenLight.visible = true
		redLight.visible = false
	else:
		animator.play("LeverAction", -1, -1, true)
		greenLight.visible = false
		redLight.visible = true
	
	
