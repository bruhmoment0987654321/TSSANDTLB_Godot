extends Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = "X " + str(SaveManager.sign_coin_total)
