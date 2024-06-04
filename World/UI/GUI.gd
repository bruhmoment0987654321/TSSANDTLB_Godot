extends CanvasLayer

@onready var ammo_bar = $AmmoBar

@onready var the_boy_exists = is_instance_valid($"../TheBoy")
func _process(delta):
	if the_boy_exists:
		ammo_bar.visible = true
