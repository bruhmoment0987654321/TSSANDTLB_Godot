extends TabBar

func _ready():
	%Master.value = SaveManager.config.get_value("Audio","0")
	%Music.value = SaveManager.config.get_value("Audio","1")
	%SFX.value = SaveManager.config.get_value("Audio","2")
	
	AudioServer.set_bus_volume_db(0,linear_to_db(%Master.value))
	AudioServer.set_bus_volume_db(1,linear_to_db(%Music.value))
	AudioServer.set_bus_volume_db(2,linear_to_db(%SFX.value))

func _on_master_value_changed(value):
	set_volume(0,value)


func _on_music_value_changed(value):
	set_volume(1,value)


func _on_sfx_value_changed(value):
	set_volume(2,value)

func set_volume(idx,value):
	AudioServer.set_bus_volume_db(idx,linear_to_db(value))
	
	SaveManager.config.set_value("Audio",str(idx),value)
	SaveManager.save_settings()
