extends Node

const saved_path = "user://save_file.save"

var config = ConfigFile.new()
var sign_coin_total = 0
var sign_coin_list = {}

func _ready():
	load_data()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_data()

func save_data():
	print("Saved Data")
	config.set_value("the sign coin count","sign_coin_total",sign_coin_total)
	config.save(saved_path)
	
func load_data():
	if FileAccess.file_exists(saved_path):
		print("Loaded Data!")
		var err = config.load(saved_path)
		
		sign_coin_total = config.get_value("the sign coin count","sign_coin_total")
		
		for key in config.get_section_keys("sign_coin_list"):
			sign_coin_list[key] = config.get_value("sign_coin_list",key)
		
		print("sign_coin_total : " + str(sign_coin_total))
		print(sign_coin_list)
	else:
		print("There is no data")
		sign_coin_list = {}
		sign_coin_total = 0
