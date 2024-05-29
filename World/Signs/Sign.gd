extends Area2D
@onready var sprite = $AnimationPlayer
@onready var interact = $Interact

## Place Dialog Here
@export_multiline var text : String
@onready var accept_dialog = $Dialog

var talking = false

var occupied = false
func _ready():
	sprite.play("idle")
	
func _process(delta):
	if occupied:
		if Input.is_action_just_pressed("up"):
			sprite.play("talk")
			talking = true
			accept_dialog.visible = true
			accept_dialog.dialog_text = text
		interact.visible = true
	else:
		interact.visible = false

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

func _on_dialog_confirmed():
	sprite.play("idle")

func _on_body_entered(body):
	occupied = true

func _on_body_exited(body):
	occupied = false
	accept_dialog.visible = false
