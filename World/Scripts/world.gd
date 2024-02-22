extends Node2D
@onready var level_completed = $CanvasLayer/LevelCompleted

@export var next_level:PackedScene

@export var Background = Color.BLACK 
func _ready():
	RenderingServer.set_default_clear_color(Background)
	Global.level_completed.connect(show_level_completed)

func show_level_completed():
	get_tree().paused = true
	if not next_level is PackedScene: return
	level_completed.show()
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
	LevelTransition.fade_from_black()
