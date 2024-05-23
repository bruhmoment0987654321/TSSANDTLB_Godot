extends Node2D
var node_parent = -1
var _scale = Vector2(1,1);
@export var spd = 0.05

func _ready():
	var node_parent = get_parent()
	var _scale = node_parent.scale
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	_scale.x = approach(_scale.x,1,spd*delta)
	_scale.y = approach(_scale.y,1,spd*delta)

func approach(start,end,shift):
	if start < end:
		return min(start + shift,end)
	else:
		return max(start - shift,end)

func gummy(xscale,yscale):
	_scale.x = xscale
	_scale.y = yscale
