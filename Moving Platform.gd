extends Path2D

@onready var path_follow_2d = $PathFollow2D
@onready var animation_player = $AnimationPlayer
@onready var animated_sprite_2d = $AnimatableBody2D/AnimatedSprite2D

@export var loop = true
@export var speed = 2.0
@export var speed_scale = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	animated_sprite_2d.play("default")
	if not loop:
		animation_player.play("move")
		animation_player.speed_scale = speed_scale
		set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(delta):
	path_follow_2d.progress += speed
