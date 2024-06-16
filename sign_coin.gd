extends Collectible

@onready var sign_coin = $"."
@onready var animation_player = $AnimationPlayer
@onready var collider = $Collider

@export_range(0.1,10) var amp: float = 1.0
@export_range(0.1,10) var frequency: float = 1.0

var anchor_y = 0
var timer = 0

func _ready():
	anchor_y = sign_coin.global_position.y
	animation_player.play("Spin")

func _process(delta):
	sign_coin.global_position.y = anchor_y + sin(timer * frequency)*amp
	timer += delta

func _on_body_entered(body):
	collider.disabled = true
	animation_player.play("Picked Up")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Picked Up":
		Global.sign_coin_total += 1
		queue_free()
