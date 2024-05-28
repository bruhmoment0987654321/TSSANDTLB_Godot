extends Node2D
@export var speed_scale = 1.0
@onready var animationplayer = $"ParallaxBackground/Layer 5/animationplayer"
@onready var layer_1 = $"ParallaxBackground/Layer 1"
@onready var layer_2 = $"ParallaxBackground/Layer 2"
@onready var layer_3 = $"ParallaxBackground/Layer 3"
@onready var layer_4 = $"ParallaxBackground/Layer 4"

# Called when the node enters the scene tree for the first time.
func _ready():
	animationplayer.play("default")
	animationplayer.speed_scale = speed_scale

func _process(delta):
	layer_1.motion_offset.x -= 0.1
	layer_2.motion_offset.x += 0.2
	layer_3.motion_offset.x -= 0.4
	layer_4.motion_offset.x += 0.6
