extends Sprite2D
@onready var tween:Tween = get_tree().create_tween()
tween.set_trans(Tween.EASE_OUT)
func _ready():
	
