extends Node2D
#te borders and stuff
@onready var collision_polygon2D = $"The World/CollisionPolygon2D"
@onready var polygon2D = $"The World/CollisionPolygon2D/Polygon2D"

@onready var camera = $Slime_player/Camera2D
@export_group("Camera Limit")
@export var left = -8
@export var right = 656
@export var top = -16
@export var bottom = 376
@export var Background = Color.BLACK 
func _ready():
	camera.limit_top = top
	camera.limit_bottom = bottom
	camera.limit_left = left
	camera.limit_right = right
	RenderingServer.set_default_clear_color(Background)
	polygon2D.polygon = collision_polygon2D.polygon
