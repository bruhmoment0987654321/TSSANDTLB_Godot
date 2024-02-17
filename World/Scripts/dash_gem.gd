extends Collectible
class_name DashGem

func _on_body_entered(body):
	queue_free()
	Global.dash_amount += 1
