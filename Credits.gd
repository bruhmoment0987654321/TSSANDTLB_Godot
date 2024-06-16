extends Node2D
@onready var words = $Words
@onready var skull = $Skull
@onready var feedback_button = %"Feedback Button"

@export var music = preload("res://Music/Demo-end (By Jake Russel).wav")
@export var credit_speed = 16
@export var transition_FX = preload("res://Music/transition.wav")
var start_menu = load("res://Start Scene.tscn")
var fade = false
var text = "Credits\n\nLevel Design - Me\n\nArt - Me\n\nMusic - Me (besides one song...)\n\n\n"+ str(Global.death_count)+"""

"Sewer Theme" - Me

"Title Theme" - Me

"Space Theme" - Me

"Demo ED" - Jake Russel



Thank you for playing the demo. I hope you had fun. 
Of course, there will be more soon. 
You just have to wait a bit.

Also, you can press Escape to exit the game."""
func _ready():
	AudioManager.play_music(music,-80)
	words.text = text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if AudioManager.volume_db < 0.0:
		AudioManager.volume_db += 0.5
	if words.position.y > -900:
		words.position.y -= credit_speed*delta
		skull.position.y -= credit_speed*delta
		feedback_button.position.y -= credit_speed*delta
	if fade:
		AudioManager.volume_db -= 5
	if Input.is_action_just_pressed("exit_game"):
		AudioManager.play_FX(transition_FX)
		
		await LevelTransition.fade_to_black()
		if LevelTransition.animation_playing():
			get_tree().change_scene_to_packed(start_menu)
			LevelTransition.fade_from_black()

func _on_feedback_button_pressed():
	OS.shell_open("https://forms.gle/c5dz8yyoXRq2pGHM9")
