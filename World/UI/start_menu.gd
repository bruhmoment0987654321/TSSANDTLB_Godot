extends CanvasLayer

@onready var play_as_slime = %"Play As Slime"
@onready var play_as_boy = %"Play As Boy"

@export var slime_level : PackedScene
@export var boy_level : PackedScene

func _on_start_game_button_pressed():
	await LevelTransition.fade_to_black()
	if LevelTransition.animation_playing():
		get_tree().change_scene_to_packed(slime_level)
		LevelTransition.fade_from_black()


func _on_play_as_boy_pressed():
	await LevelTransition.fade_to_black()
	if LevelTransition.animation_playing():
		get_tree().change_scene_to_packed(boy_level)
		LevelTransition.fade_from_black()

func _on_quit_button_pressed():
	get_tree().quit()


