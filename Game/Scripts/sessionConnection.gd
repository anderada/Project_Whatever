extends Label

func _ready() -> void:
	Telemetry.set_section("Woe")
	if Telemetry.has_authenticated():
		_on_authenticated(true, Telemetry.get_session_id())
	
func _on_authenticated(success, info):
	if success:
		if info < 0:
			text = "Offline Session #" + str(info)
			
		else:
			text = "Server Session #" + str(info)
				
	else:
		text = info
