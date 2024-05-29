extends CanvasLayer

@onready var play_as_slime = %"Play As Slime"
@onready var play_as_boy = %"Play As Boy"

@export var music = preload("res://Music/Title_song.wav")
@export var transition_FX = preload("res://Music/transition.wav")
@export var slime_level : PackedScene
@export var boy_level : PackedScene

var fade = false

func _ready():
	AudioManager.play_music(music)

func _process(delta):
	if fade:
		AudioManager.volume_db -= 5

func _on_start_game_button_pressed():
	fade = true
	AudioManager.play_FX(transition_FX)
	await LevelTransition.fade_to_black()
	if LevelTransition.animation_playing():
		get_tree().change_scene_to_packed(slime_level)
		LevelTransition.fade_from_black()

func _on_play_as_boy_pressed():
	fade = true 
	AudioManager.play_FX(transition_FX)
	await LevelTransition.fade_to_black()
	if LevelTransition.animation_playing():
		get_tree().change_scene_to_packed(boy_level)
		LevelTransition.fade_from_black()

func _on_quit_button_pressed():
	get_tree().quit()


