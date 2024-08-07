extends CanvasLayer
@onready var sign_coin = $"Start UI/Sign Coin"
@onready var sign_coin_counter = $"Start UI/Sign Coin Counter"
@onready var main_menu = $"Start UI/Main Menu"
@onready var customization_menu = $"Start UI/Customization Menu"
@onready var start_ui = $"Start UI"
@onready var level_select = $"Level Select"

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
	
	if SaveManager.sign_coin_total > 0:
		sign_coin.visible = true
		sign_coin_counter.visible = true
	
	sign_coin_counter.text = "Coin Count: " + str(SaveManager.sign_coin_total) + "/" + str(Global.max_sign_coins)

func _on_slime_button_pressed():
	fade = true
	AudioManager.play_FX(transition_FX)
	await LevelTransition.fade_to_black()
	if LevelTransition.animation_playing():
		get_tree().change_scene_to_packed(slime_level)
		LevelTransition.fade_from_black()

func _on_boy_button_pressed():
	fade = true 
	AudioManager.play_FX(transition_FX)
	await LevelTransition.fade_to_black()
	if LevelTransition.animation_playing():
		get_tree().change_scene_to_packed(boy_level)
		LevelTransition.fade_from_black()

func _on_quit_button_pressed():
	get_tree().quit()

func _on_settings_button_pressed():
	main_menu.show()

func _on_customization_button_pressed():
	customization_menu.show()

func _on_time_mode_button_pressed():
	start_ui.hide()
	level_select.show()

func _on_exit_button_pressed():
	level_select.hide()
	start_ui.show()
