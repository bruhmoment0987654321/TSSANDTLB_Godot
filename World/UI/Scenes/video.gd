extends TabBar

func _ready():
	var screen_type = SaveManager.config.get_value("Video","fullscreen")
	var borderless_type = SaveManager.config.get_value("Video","borderless")
	var vsync_type = SaveManager.config.get_value("Video","vsync")
	
	if screen_type == DisplayServer.WINDOW_MODE_FULLSCREEN:
		%"Fullscreen Button".button_pressed = true
	if borderless_type:
		%"Borderless Button".button_pressed = true
	%"Vsync Button".selected = vsync_type

func _on_fullscreen_button_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		SaveManager.config.set_value("Video","fullscreen",DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		SaveManager.config.set_value("Video","fullscreen",DisplayServer.WINDOW_MODE_WINDOWED)
	
	SaveManager.save_settings()

func _on_borderless_button_toggled(toggled_on):
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,toggled_on)
	SaveManager.config.set_value("Video","borderless",toggled_on)
	SaveManager.save_settings()

func _on_vsync_button_item_selected(index):
	DisplayServer.window_set_vsync_mode(index)
	SaveManager.config.set_value("Video","vsync",index)
	SaveManager.save_settings()
