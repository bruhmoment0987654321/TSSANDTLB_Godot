extends Area2D

@onready var sprite = $AnimatedPlayer
@onready var screen = $Screen

func _ready():
	sprite.play("idle")

func _on_body_entered(body):
	sprite.play("turn_on")
	sprite.queue("on")

func _on_body_exited(body):
	sprite.play("turn_off")
	sprite.queue("idle")
