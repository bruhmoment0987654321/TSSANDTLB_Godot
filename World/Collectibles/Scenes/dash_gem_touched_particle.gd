extends CPUParticles2D

@onready var animation_player = $AnimationPlayer

func _process(delta):
	if emitting:
		animation_player.play("zoom out")
