extends CanvasLayer

@onready var ammo_bar = $AmmoBar
@onready var sign_coin = $"Sign Coin"

@onready var the_boy_exists = is_instance_valid($"../TheBoy")

func _ready():
	sign_coin.play("default")

func _process(delta):
	if the_boy_exists:
		ammo_bar.visible = true
