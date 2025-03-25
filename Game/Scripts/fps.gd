extends Label

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	text = str(Engine.get_frames_per_second())
