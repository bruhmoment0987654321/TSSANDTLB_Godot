extends Node2D
#te borders and stuff
@onready var collision_polygon2D = $"The World/CollisionPolygon2D"
@onready var polygon2D = $"The World/CollisionPolygon2D/Polygon2D"

@export var Background = Color.BLACK 
func _ready():
	RenderingServer.set_default_clear_color(Background)
	polygon2D.polygon = collision_polygon2D.polygon
