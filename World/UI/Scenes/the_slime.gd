extends TabBar

@onready var slime = $HBoxContainer/VBoxContainer/HBoxContainer/NinePatchRect/Slime
@onready var cosmetic_name = $"HBoxContainer/VBoxContainer/Cosmetic Name"
@onready var accessory = $HBoxContainer/VBoxContainer/HBoxContainer/NinePatchRect/Accessory
@onready var label_location = $"HBoxContainer/VBoxContainer/HBoxContainer/Label Location"

@export var popup_label : PackedScene
var displayed_text = ""

var cosmetic_keys = []
var current_key_index = 0
var displayed_cosmetic = null

func _ready():
	set_sprite_keys()
	update_sprite()
	slime.play("Idle")

func _process(delta):
	for label in get_tree().get_nodes_in_group("Floating Text"):
		label.pivot_offset = Vector2(label.size/2)
		label.position = label_location.global_position - Vector2(label.size/2)

func set_sprite_keys():
	cosmetic_keys = Global.slime_cosmetics.keys()

func update_sprite():
	var current_sprite = cosmetic_keys[current_key_index]
	if current_sprite == "None":
		accessory.sprite_frames = null
		displayed_cosmetic = "None"
	else: 
		accessory.sprite_frames = Global.slime_cosmetics[current_sprite]
		displayed_cosmetic = current_sprite
		
	cosmetic_name.text = current_sprite
	displayed_text = current_sprite + " Equipped!"
	if accessory.sprite_frames != null:
		accessory.play("Display")
		accessory.frame = 0

func popup():
	var inst = popup_label.instantiate()
	inst.text = displayed_text
	get_tree().current_scene.add_child(inst)
	

func _on_left_button_pressed():
	current_key_index = (current_key_index - 1) % cosmetic_keys.size()
	update_sprite()

func _on_right_button_pressed():
	current_key_index = (current_key_index + 1) % cosmetic_keys.size()
	update_sprite()

func _on_equip_button_pressed():
	var check_popup = get_tree().get_nodes_in_group("Floating Text")
	if not check_popup:
		print("Spawn!")
		popup()
	SaveManager.config.set_value("Cosmetic","slime_cosmetic",displayed_cosmetic)
	print(displayed_text)
