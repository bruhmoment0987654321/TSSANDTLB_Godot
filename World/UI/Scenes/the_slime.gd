extends TabBar

@onready var slime = $HBoxContainer/VBoxContainer/HBoxContainer/NinePatchRect/Slime
@onready var cosmetic_name = $"HBoxContainer/VBoxContainer/Cosmetic Name"
@onready var accessory = $HBoxContainer/VBoxContainer/HBoxContainer/NinePatchRect/Accessory
@onready var label_location = $"HBoxContainer/VBoxContainer/HBoxContainer/Label Location"
@onready var unlock_by_label = $"HBoxContainer/VBoxContainer/HBoxContainer/NinePatchRect/Unlock By Label"

@export var popup_label : PackedScene
var displayed_text = ""
var equipped_pressed = false

var cosmetic_keys = []
var cosmetic_unlocked = []
var current_key_index = 0
var displayed_cosmetic = null

func _ready():
	set_sprite_keys()
	update_sprite()
	slime.play("Idle")

func _process(delta):
	for label in get_tree().get_nodes_in_group("Floating Text"):
		label.pivot_offset = Vector2(label.size/2)
		label.position = label_location.position - Vector2(label.size/2)

func set_sprite_keys():
	cosmetic_keys = Global.slime_cosmetics.keys()
	cosmetic_unlocked = Global.slime_cosmetics.keys()

func update_sprite():
	var current_sprite = cosmetic_keys[current_key_index]
	if current_sprite == "None":
		accessory.sprite_frames = null
		displayed_cosmetic = "None"
	else: 
		accessory.sprite_frames = Global.slime_cosmetics[current_sprite]
		displayed_cosmetic = current_sprite
	
	unlock_by_label.text = "Equipped"
	
	match current_sprite:
		"None":
			unlock_by_label.text = ""
			if current_sprite == SaveManager.selected_cosmetic_slime:
				unlock_by_label.text = "Equipped"
		"Propeller Hat":
			if SaveManager.max_sign_coins_reached:
				unlock_by_label.text = ""
				accessory.material.set_shader_parameter("flash_modifier",0)
				cosmetic_unlocked[current_key_index] = true
			else:
				unlock_by_label.text = "Get all sign coins"
				accessory.material.set_shader_parameter("flash_modifier",1)
				cosmetic_unlocked[current_key_index] = false
			
			if current_sprite == SaveManager.selected_cosmetic_slime:
				unlock_by_label.text = "Equipped"
		"Crown":
			unlock_by_label.text = ""
			accessory.material.set_shader_parameter("flash_modifier",0)
			cosmetic_unlocked[current_key_index] = true
			
			if current_sprite == SaveManager.selected_cosmetic_slime:
				unlock_by_label.text = "Equipped"
	
	cosmetic_name.text = current_sprite
	displayed_text = current_sprite + " Equipped!"
	if accessory.sprite_frames != null:
		accessory.play("Display")
		accessory.frame = 0
	equipped_pressed = false

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
	if cosmetic_unlocked[current_key_index] and not equipped_pressed:
		print("Spawn!")
		popup()
		SaveManager.selected_cosmetic_slime = displayed_cosmetic
		SaveManager.config.set_value("Cosmetic","slime_cosmetic",displayed_cosmetic)
		unlock_by_label.text = "Equipped"
		print(displayed_text)
		equipped_pressed = true
	elif not cosmetic_unlocked[current_key_index]:
		print("Not unlocked :[")
