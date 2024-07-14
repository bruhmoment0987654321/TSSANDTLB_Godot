extends Node

signal level_completed

signal add_dash_amount

signal max_sign_coins_reached

signal set_camera_target(entity : Node2D)

var coins = 0
var dash_amount = 0
var ammo = 0
var death_count = 0
var max_sign_coins = 8

var slime_cosmetics = {
	"None" : null,
	"Propeller Hat" : preload("res://Player/Slime_Player/Sprites/Accessories/Propeller Hat/slime_propeller_hat.tres"),
	"Crown" : preload("res://Player/Slime_Player/Sprites/Accessories/Crown/slime_crown.tres"),
}
var slime_cosmetic_on_death = {
	"None" : null,
	"Propeller Hat" : preload("res://Player/Slime_Player/Sprites/Accessories/Propeller Hat/pinhat.png"),
	"Crown" : preload("res://Player/Slime_Player/Sprites/Accessories/Crown/crown.png"),
}

var the_boy_cosmetics = {
	"None" : preload("res://Player/The Boy/Sprites/Accesories/Default/default_boy_accessory.tres"),
	"A Cool Hat" : preload("res://Player/The Boy/Sprites/Accesories/Cool Hat/boy_cool_hat.tres"),
	"Crown" : preload("res://Player/The Boy/Sprites/Accesories/Crown/boy_crown.tres"),
}

var boy_cosmetic_on_death = {
	"None" : null,
	"A Cool Hat" : preload("res://Player/The Boy/Sprites/Accesories/Cool Hat/a_cool_hat.png"),
	"Crown" : preload("res://Player/The Boy/Sprites/Accesories/Crown/Boy_crown.png"),
}

func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	#check if you have reached the max amount of sign coins in the game 
	if SaveManager.sign_coin_total == max_sign_coins:
		max_sign_coins_reached.emit()

static func chance(percent_num):
	return percent_num > randf()

func emit_set_camera_target(entity : Node2D) -> void:
	set_camera_target.emit(entity)



