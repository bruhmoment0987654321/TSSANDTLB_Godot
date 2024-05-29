extends ParallaxBackground

@onready var layer_1 = $"Layer 1"
@onready var layer_2 = $"Layer 2"
@onready var layer_3 = $"Layer 3"
@onready var layer_4 = $"Layer 4"

@export var speed_scale = 1.0
var get_owner = owner
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if owner.is_in_group("Start Menu"):
		layer_1.motion_offset.x += 0.1 *speed_scale
		layer_2.motion_offset.x += 0.2 *speed_scale
		layer_3.motion_offset.x += 0.3 *speed_scale
		layer_4.motion_offset.x += 0.4 *speed_scale
