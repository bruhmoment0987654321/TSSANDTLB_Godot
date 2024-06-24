extends Button

@onready var main_menu = $"../../../.."


func _on_pressed():
	main_menu.hide()
