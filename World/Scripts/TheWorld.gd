extends StaticBody2D
class_name Theworld

@onready var polygon2d = $CollisionPolygon2D/Polygon2D
@onready var collision_polygon2d = $CollisionPolygon2D
func _ready():
	polygon2d.polygon = collision_polygon2d.polygon
