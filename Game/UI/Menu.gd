extends Node

@export var mainScene: PackedScene
@export var OptionsScene: PackedScene

@onready var panel = $"TeamInfo/TeamInfo"   # 获取 UI 节点
@onready var timer = $"TeamInfo/Timer"   # 获取计时器

func _ready():
	panel.modulate.a = 0
	timer.timeout.connect(_hide_panel)
	
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(mainScene)


func _on_option_button_pressed() -> void:
	var options = load("").instance()
	get_tree().current_scene.add_child(options)

func _on_team_button_down() -> void:
	if panel.modulate.a > 0:
		_hide_panel()
	else:
		panel.modulate.a = 1
		timer.start()
func _hide_panel():
	panel.modulate.a = 0
	timer.stop()
