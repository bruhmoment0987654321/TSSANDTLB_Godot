extends Node2D
@onready var level_completed = $CanvasLayer/LevelCompleted

@export var Background = Color.BLACK 
func _ready():
	RenderingServer.set_default_clear_color(Background)
	Global.level_completed.connect(show_level_completed)
	
func show_level_completed():
	level_completed.show()
	get_tree().paused = true
