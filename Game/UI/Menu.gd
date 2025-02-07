extends Node

@export var mainScene: PackedScene
@export var OptionsScene: PackedScene

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(mainScene)


func _on_option_button_pressed() -> void:
	var options = load("").instance()
	get_tree().current_scene.add_child(options)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
