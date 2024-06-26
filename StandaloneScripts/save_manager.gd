extends Node

const saved_path = "user://save_file.save"
const settings_path = "user://settings.cfg"

var config = ConfigFile.new()
var sign_coin_total = 0
var sign_coin_list = {}
var selected_cosmetic_slime = ""
var selected_cosmetic_boy = ""
var max_sign_coins_reached = false

func _ready():
	config.set_value("Video","fullscreen",DisplayServer.window_get_mode())
	config.set_value("Video","borderless",false)
	config.set_value("Video","vsync",DisplayServer.VSYNC_ENABLED)
	Global.connect("max_sign_coins_reached",update_max_sign_coins_reached)
	
	for i in range(3):
		config.set_value("Audio",str(i),0.0)
	load_data()
	load_settings()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_data()

func save_data():
	print("Saved Data")
	config.set_value("sign coin","sign_coin_total",sign_coin_total)
	config.set_value("sign coin", "max_sign_coins_reached", max_sign_coins_reached)
	config.save(saved_path)


func load_data():
	if FileAccess.file_exists(saved_path):
		print("Loaded Data!")
		var err = config.load(saved_path)
		
		selected_cosmetic_slime = config.get_value("Cosmetic","slime_cosmetic")
		selected_cosmetic_boy = config.get_value("Cosmetic","boy_cosmetic")
		
		sign_coin_total = config.get_value("sign coin","sign_coin_total")
		max_sign_coins_reached = config.get_value("sign coin","max_sign_coins_reached")
		
		for key in config.get_section_keys("sign_coin_list"):
			sign_coin_list[key] = config.get_value("sign_coin_list",key)
		
		print("Equipped Slime Cosmetic: " + str(selected_cosmetic_slime))
		print("Equipped Boy Cosmetic: " + str(selected_cosmetic_boy))
		
		print("sign_coin_total : " + str(sign_coin_total))
		print("max_sign_coins_reached : " + str(max_sign_coins_reached))
		print(sign_coin_list)
	else:
		print("There is no data")
		sign_coin_list = {}
		sign_coin_total = 0
		selected_cosmetic_slime = 0
		max_sign_coins_reached = false

func save_settings():
	config.save(settings_path)
	print("Saved Settings!")

func update_max_sign_coins_reached():
	max_sign_coins_reached = true

func load_settings():
	if config.load(settings_path) != OK:
		save_settings()
	print("Loaded Settings!")
	load_video_settings()
	print("Master Volume: "+ str(config.get_value("Audio","0") * 100) + "%")
	print("Music Volume: "+ str(config.get_value("Audio","1") * 100) + "%")
	print("SFX Volume: "+ str(config.get_value("Audio","2") * 100) + "%")

func load_video_settings():
	var screen_type = config.get_value("Video","fullscreen")
	var borderless = config.get_value("Video","borderless")
	var vsync_index = config.get_value("Video","vsync")
	
	print("Fullscreen Mode: " + str(screen_type))
	print("Borderless: " + str(borderless))
	print("Vsync Mode: " + str(vsync_index))
	
	DisplayServer.window_set_mode(screen_type)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,borderless)
	DisplayServer.window_set_vsync_mode(vsync_index)
