extends Collectible
@onready var sign_coin_sprite = $"Sign Coin Sprite"
@onready var sign_coin = $"."
@onready var animation_player = $AnimationPlayer
@onready var collider = $Collider

@export var sign_coin_name : String = "Level Name & Coin #"
@export_range(0.1,10) var amp: float = 1.0
@export_range(0.1,10) var frequency: float = 1.0
@export var touched_color = Color.WHITE

var sign_dict = {"ID" : "" ,"Collected" : 0}
var anchor_y = 0
var timer = 0

func _ready():
	sign_dict["ID"] = sign_coin_name
	if not SaveManager.sign_coin_list.is_empty():
		if SaveManager.sign_coin_list.has(sign_dict["ID"]):
			sign_dict["Collected"] = SaveManager.sign_coin_list[sign_dict["ID"]]
	if sign_dict["Collected"]:
		sign_coin_sprite.modulate = touched_color
	anchor_y = sign_coin.global_position.y
	animation_player.play("Spin")

func _process(delta):
	sign_coin.global_position.y = anchor_y + sin(timer * frequency)*amp
	timer += delta

func _on_body_entered(body):
	animation_player.play("Picked Up")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Picked Up" and not sign_dict["Collected"]:
		SaveManager.sign_coin_total += 1
		SaveManager.sign_coin_list[sign_dict["ID"]] = sign_dict["Collected"]
		SaveManager.config.set_value("sign_coin_list",sign_dict["ID"],sign_dict["Collected"])
		print(SaveManager.sign_coin_list)
		queue_free()
