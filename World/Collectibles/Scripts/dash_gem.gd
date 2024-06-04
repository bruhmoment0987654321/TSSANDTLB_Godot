extends Collectible
class_name DashGem
@onready var timer = $Timer
@export var spawn_time = 1.0
var first_time = true

func _process(delta):
	if timer.time_left == 0.0:
		sprite.visible = true

func _on_body_entered(body):
	if sprite.visible:
		Global.dash_amount += 1
		Global.ammo = 100
		timer.start()
		first_time = false
		sprite.visible = false
