extends Label

func _on_telemetry_authenticated(success, info) -> void:
	if success:
		if info < 0:
			text = "Offline Session #" + str(info)
		else:
			text = "Server Session #" + str(info)
	else:
		text = info
