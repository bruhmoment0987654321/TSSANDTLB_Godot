extends Node2D

@onready var level_completed = $GUI/LevelCompleted

@export var music = preload("res://Music/space.wav")

@export var trans_fx = preload("res://Music/transition.wav")

@export var next_level:PackedScene

@export var Background = Color.BLACK 
func _ready():
	AudioManager.play_music(music,-80)
	Global.level_completed.connect(show_level_completed)

func _process(delta):
	if AudioManager.volume_db < 0.0:
		AudioManager.volume_db += 1

func show_level_completed():
	AudioManager.volume_db = -80
	AudioManager.play_FX(trans_fx)
	get_tree().paused = true
	level_completed.show()
	await get_tree().create_timer(0.7).timeout
	if not next_level is PackedScene: return
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
	LevelTransition.fade_from_black()

