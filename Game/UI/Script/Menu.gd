extends Node

@export var mainScene: PackedScene

@onready var optionsMenu= $OptionsMenu
@onready var mainMenu= $MainUIElements
@onready var panel = $MainUIElements/TeamInfo/TeamInfo
@onready var timer = $MainUIElements/TeamInfo/Timer

func _ready():
	panel.modulate.a = 0
	timer.timeout.connect(_hide_panel)
	optionsMenu.exit_options_menu.connect(_on_exit_options_menu)
	
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(mainScene)


func _on_option_button_pressed() -> void:
	mainMenu.visible=false
	optionsMenu.set_process(true)
	optionsMenu.visible=true

func _on_team_button_down() -> void:
	if panel.modulate.a > 0:
		_hide_panel()
	else:
		panel.modulate.a = 1
		timer.start()
func _hide_panel():
	panel.modulate.a = 0
	timer.stop()
	
func _on_exit_options_menu() -> void:
	mainMenu.visible=true
	optionsMenu.visible=false


func _on_exit_button_button_up() -> void:
	get_tree().quit()
