extends Camera2D

@export var shake_fade : float = 5.0

var rng = RandomNumberGenerator.new()
var random_strength : float = 0
var shake_strength = 0.0
var shake_angle = 0

func _process(delta):
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength,0,shake_fade*delta)
		shake_angle = lerpf(shake_angle,0,shake_fade*delta)
		offset = random_offset()

func apply_shake(_shake_amount):
	random_strength = _shake_amount
	shake_strength = random_strength
func random_offset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength,shake_strength),rng.randf_range(-shake_strength,shake_strength))