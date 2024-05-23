extends CenterContainer

@onready var start_game_button = %StartGameButton
@export var first_level : String = "res://World/Levels/TheSewer/tutorial.tscn"

func _ready():
	start_game_button.grab_focus()

func _on_start_game_button_pressed():
	await LevelTransition.fade_to_black()
	if LevelTransition.animation_playing():
		get_tree().change_scene_to_file(first_level)
		LevelTransition.fade_from_black()


func _on_quit_button_pressed():
	get_tree().quit()
