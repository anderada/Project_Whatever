extends Panel

@export var camera:Camera3D
@export var letterClose:Button
@export var letter1:TextureRect
@export var letter2:TextureRect
@export var letter3:TextureRect
@export var letter4:TextureRect
@export var justOpened:bool = false

func _process(_delta: float) -> void:
	if(!justOpened && Input.is_action_just_pressed("next_action")):
		_on_letter_close_pressed()
	elif(justOpened):
		justOpened = false

func _on_letter_close_pressed() -> void:
	camera.lockCamera(false)
	letterClose.visible = false
	letter1.visible = false
	letter2.visible = false
	letter3.visible = false
	letter4.visible = false
	visible = false
