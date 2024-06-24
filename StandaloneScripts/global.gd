extends Node

signal level_completed

signal add_dash_amount

signal set_camera_target(entity : Node2D)

var slime_cosmetics = {
	"None" : null,
	"Propeller Hat" : preload("res://Player/Slime_Player/Sprites/Accessories/Propeller Hat/slime_propeller_hat.tres"),
	"Crown" : preload("res://Player/Slime_Player/Sprites/Accessories/Crown/slime_crown.tres")
}
var slime_cosmetic_on_death = {
	"None" : null,
	"Propeller Hat" : preload("res://Player/Slime_Player/Sprites/Accessories/Propeller Hat/pinhat.png"),
	"Crown" : preload("res://Player/Slime_Player/Sprites/Accessories/Crown/crown.png")
}
var coins = 0
var dash_amount = 0
var ammo = 0
var death_count = 0
var max_sign_coins = 7

func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

static func chance(percent_num):
	return percent_num > randf()

func emit_set_camera_target(entity : Node2D) -> void:
	set_camera_target.emit(entity)



