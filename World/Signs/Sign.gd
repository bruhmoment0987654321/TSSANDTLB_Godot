extends Area2D
@onready var sprite = $AnimationPlayer
var talking = false
# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.play("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("up"):
		sprite.play("talk")
		talking = true


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "idle":
		if Global.chance(0.4):
			if Global.chance(0.5):
				sprite.play("move_left")
			else:
				sprite.play("move_right")
			sprite.queue("idle")
		else:
			sprite.play("idle")
	
	if anim_name == "talk":
		sprite.play("talk")
