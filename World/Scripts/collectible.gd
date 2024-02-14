extends Node
class_name Collectible
@onready var sprite = $AnimatedSprite2D

func _ready():
	sprite.play("default")
