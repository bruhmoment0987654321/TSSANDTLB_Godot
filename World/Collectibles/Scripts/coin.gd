extends Collectible
@onready var coin = $"."

func _on_body_entered(body):
	queue_free()
	Global.coins += 1
