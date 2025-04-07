extends Control

signal exit_options_menu
@onready var startMenuScene: PackedScene = load("res://UI/StartMenu.tscn")
@onready var confirmPanel=$MarginContainer/Confirm_Panel

func _ready() -> void:
	set_process(false)

func _on_return_to_main_menu() -> void:
	get_tree().change_scene_to_packed(startMenuScene)

func _on_back_button_up() -> void:
	exit_options_menu.emit()
	set_process(false)


func _on_main_menu_button_up() -> void:
	confirmPanel.visible=true


func _on_no_button_up() -> void:
	confirmPanel.visible=false
