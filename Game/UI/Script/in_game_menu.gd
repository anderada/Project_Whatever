extends Control

signal exit_options_menu
@onready var startMenuScene: PackedScene = load("res://UI/StartMenu.tscn")
@onready var confirmPanel=$MarginContainer/Confirm_Panel
@onready var letterPanel=$MarginContainer/Letter_Panel
var allowclose=true;

@onready var letterIcons := [%letter1,%letter2,%letter3,%letter4]
@onready var letters :=[%Letter1,%Letter2,%Letter3,%Letter4]
var currentLetter:int

func _ready() -> void:
	set_process(false)
	for i in range(letterIcons.size()):
		letterIcons[i].connect("pressed", Callable(self, "showletter").bind(i))
		letterIcons[i].visible=false
	InventoryData.updateInventory.connect(collect_item)

func _on_return_to_main_menu() -> void:
	get_tree().change_scene_to_packed(startMenuScene)

func _on_back_button_up() -> void:
	exit_options_menu.emit()
	set_process(false)


func _on_main_menu_button_up() -> void:
	confirmPanel.visible=true
	allowclose=false

func _on_no_button_up() -> void:
	confirmPanel.visible=false
	allowclose=true

func showletter(id:int):
	letterPanel.visible=true
	letters[id].visible=true
	currentLetter=id
	allowclose=false

func _on_letter_close_pressed() -> void:
	letterPanel.visible=false
	letters[currentLetter].visible=true
	allowclose=true

func collect_item(id: int) -> void:
	letterIcons[id].visible=true
