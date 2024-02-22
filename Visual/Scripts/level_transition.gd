extends CanvasLayer

@onready var anim_player = $AnimationPlayer

func fade_from_black():
	anim_player.play("fade_from_black")
	await anim_player.animation_finished

func fade_to_black():
	anim_player.play("fade_to_black")
	await anim_player.animation_finished
