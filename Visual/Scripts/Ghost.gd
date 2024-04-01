extends Sprite2D
@onready var tween : Tween = get_tree().create_tween()
func _ready():
	tween.set_ease(Tween.EASE_OUT)
