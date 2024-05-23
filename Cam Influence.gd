extends Area2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var marker_2d = $Marker2D

##Use the original camera that is used in your levels to make this function
@onready var cam = $"../Slime_player/RemoteTransform2D"
@export var point : Vector2
@export var collision_scale : Vector2 = Vector2(1,1)
@export var collision_position : Vector2
@export var cam_speed = 0.2

var cam_original_position = 0
var entering = false
var exiting = false
func _ready():
	collision_shape_2d.scale = collision_scale
	collision_shape_2d.position = collision_position
	marker_2d.position = point

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if entering:
		cam.position = cam.position.lerp(marker_2d.position,cam_speed*delta)
		if cam.position == marker_2d.position:
			cam_original_position = cam.position
			entering = false
	if exiting:
		cam.position = cam.position.lerp(cam_original_position,cam_speed*delta)
		if cam.position == cam_original_position:
			exiting = false

func _on_body_entered(body):
	entering = true

func _on_body_exited(body):
	exiting = true
