extends Sprite2D

@export var amp = 0.1
@export var spd = 0.5
var timer = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += 1*delta
	offset.y = sin(timer*spd)*amp
