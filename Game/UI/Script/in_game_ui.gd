extends Node

@onready var optionsMenu= $InGameMenu
@onready var mainMenu= $MainUIElements
@onready var letterPanel=$InGameMenu/MarginContainer/Letter_Panel
var isopen=false

func _ready() -> void:
	optionsMenu.exit_options_menu.connect(_on_exit_options_menu)
	
func _on_option_button_pressed() -> void:
	switch_ui()
	
func _on_exit_options_menu() -> void:
	switch_ui()
	
func _unhandled_input(event):
	if event.is_action_pressed("switchMenu_action") && optionsMenu.allowclose:
		switch_ui()

func switch_ui():
	isopen=!isopen
	if isopen:
		%Camera3D.lockCamera(true)
		mainMenu.visible=false
		optionsMenu.set_process(true)
		optionsMenu.visible=true
		
	else:
		%Camera3D.lockCamera(false)
		mainMenu.visible=true
		optionsMenu.visible=false

	
