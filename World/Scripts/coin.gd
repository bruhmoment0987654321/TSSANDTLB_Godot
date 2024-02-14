extends Collectible

func _on_body_entered(body):
	queue_free()
	Global.coins += 1
	print(Global.coins)
