extends Camera2D
@export_group("Camera Functions")
@export_range(0.1,15) var camera_smoothing : float = 0.1
@export_group("Camera Shake")
@export var shake_fade : float = 5.0
@export var shake_angle_mulitplier : float = 0.05

var target : Node2D = null

var rng = RandomNumberGenerator.new()
var random_strength : float = 0
var shake_strength = 0.0
var shake_angle = 0

func _ready():
	Global.connect("set_camera_target",set_target)

func _process(delta):
	follow_target(delta)
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength,0,shake_fade*delta)
		shake_angle = lerpf(shake_angle,0,shake_fade*delta)
		offset = random_offset()
		rotation = random_rotation()

func apply_shake(_shake_amount):
	random_strength = _shake_amount
	shake_strength = random_strength
	shake_angle = random_strength*shake_angle_mulitplier

func random_offset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength,shake_strength),rng.randf_range(-shake_strength,shake_strength))

func random_rotation() -> float:
	return rng.randf_range(-shake_angle,shake_angle)

func follow_target(delta) -> void:
	if target == null:
		return
	
	position = lerp(position, target.position,camera_smoothing*delta)

func set_target(entity : Node2D) -> void:
	target = entity
