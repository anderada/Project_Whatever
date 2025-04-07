extends Node

@onready var optionsMenu= $InGameMenu
@onready var mainMenu= $MainUIElements

func _ready() -> void:
	optionsMenu.exit_options_menu.connect(_on_exit_options_menu)
	
func _on_option_button_pressed() -> void:
	mainMenu.visible=false
	optionsMenu.set_process(true)
	optionsMenu.visible=true
	
func _on_exit_options_menu() -> void:
	mainMenu.visible=true
	optionsMenu.visible=false
