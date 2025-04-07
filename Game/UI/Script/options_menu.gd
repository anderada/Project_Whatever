extends Control

signal exit_options_menu

func _ready() -> void:
	set_process(false)

func _on_exit_button_up() -> void:
	exit_options_menu.emit()
	set_process(false)
