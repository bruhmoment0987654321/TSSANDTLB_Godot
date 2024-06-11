extends Collectible

class_name DashGem

@onready var timer = $Timer
@onready var dash_gem_touched_particle = $"Dash Gem Touched Particle"


@export var spawn_time = 1.0
@export var squish_speed = 3

var activate = true

func _process(delta):
	if timer.time_left == 0.0:
		sprite.visible = true
		activate_once()
	
	squash_and_stretch(delta)

func activate_once():
	if not activate:
		turn_squishy(2,2)
		activate = true

func turn_squishy(x,y):
	sprite.scale = Vector2(x,y)
	
func squash_and_stretch(delta):
	sprite.scale.x = move_toward(sprite.scale.x,1,squish_speed*delta)
	sprite.scale.y = move_toward(sprite.scale.y,1,squish_speed*delta)

func _on_body_entered(body):
	if sprite.visible:
		Global.dash_amount += 1
		Global.ammo = 100
		timer.start()
		sprite.visible = false
		activate = false
		dash_gem_touched_particle.emitting = true
