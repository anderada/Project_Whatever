extends Control

signal exit_options_menu
@onready var startMenuScene: PackedScene = load("res://UI/StartMenu.tscn")

func _ready() -> void:
	set_process(false)

func _on_main_menu_button_up() -> void:
	get_tree().change_scene_to_packed(startMenuScene)

func _on_back_button_up() -> void:
	exit_options_menu.emit()
	set_process(false)
