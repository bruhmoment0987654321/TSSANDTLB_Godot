extends Node

signal level_completed
signal add_dash_amount
var coins = 0
var dash_amount = 0
var ammo = 0
var death_count = 0

static func chance(percent_num):
	return percent_num > randf()
	
func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
