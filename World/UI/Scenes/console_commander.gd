extends CanvasLayer

@onready var c_a_t: ConsoleAndTextchat = $ConsoleAndTextchat
@onready var slime = preload("res://Player/Slime_Player/Scenes/slime_player.tscn")
@onready var boy = preload("res://Player/The Boy/Scenes/TheBoy.tscn")

@export_group("Levels")
@export_multiline var sewer_level_dir =  "res://World/Levels/TheSewer/"
@export_multiline var moon_level_dir = "res://World/Levels/TheSewer/"

@export_group("Other Directories")
@export_multiline var enemies_dir = "res://Enemies/EnemyScenes/"
@export_multiline var collectibles_dir = "res://World/Collectibles/Scenes/"


func _ready() -> void:
	c_a_t.print_message(c_a_t.col(Color.GREEN, "Hi!"))
	c_a_t.print_message(c_a_t.bold(c_a_t.col(Color.DARK_RED, "This is the CONSOLE!!!")))
	c_a_t.print_message("Hope you like it.")
	c_a_t.print_message("I would like to thank " + c_a_t.underline("KeilainMan")+ " for having ConsoleAndTextchat")
	c_a_t.print_message("on the asset store. Makes life so much easier.")
	
	c_a_t.register_command("print",_print)
	c_a_t.register_command("no_clip",no_clip,false)
	c_a_t.register_command("spawn_enemy",spawn_enemy)
	c_a_t._on_text_input_line_text_submitted("/help")
	
	dir_contents(sewer_level_dir)
	dir_contents(moon_level_dir)
	dir_contents(enemies_dir)
	dir_contents(collectibles_dir)

func _print(args: Array):
	#print(String)
	print(" ".join(PackedStringArray(args)))
	c_a_t.print_message(" ".join(PackedStringArray(args)))

func no_clip():
	var player = get_tree().get_nodes_in_group("Player")[0] 
	player.no_clip()

func change_level(args: Array):
	pass

func spawn_enemy(args : Array):
	#spawn_enemy(name, x_position, y_position)
	var argument_count = 3
	var dir = DirAccess.open(enemies_dir)
	var enemy_name_get = " ".join(PackedStringArray(args)).split(" ",true,argument_count)
	if dir:
		match enemy_name_get[0]:
			"lilman":
				var enemy_name = "lil_man.tscn"
				var enemy_file = (enemies_dir+enemy_name).get_file()
				var position = Vector2(enemy_name_get[1].to_float(),enemy_name_get[2].to_float())
				print("Position: "+str(position))
				create_the_enemy(enemy_name,enemy_file,position)
			"bat":
				var enemy_name = "bat.tscn"
				var enemy_file = (enemies_dir+enemy_name).get_file()
				var position = Vector2(enemy_name_get[1].to_float(),enemy_name_get[2].to_float())
				print("Position: "+str(position))
				create_the_enemy(enemy_name,enemy_file,position)
			"eyesaw":
				var enemy_name = "eyesaw.tscn"
				var enemy_file = (enemies_dir+enemy_name).get_file()
				var position = Vector2(enemy_name_get[1].to_float(),enemy_name_get[2].to_float())
				print("Position: "+str(position))
				create_the_enemy(enemy_name,enemy_file,position)

func create_the_enemy(enemy_name : String,file_name,position):
	if file_name == enemy_name: 
			#spawn the enemy
			#var enemy_scene = load(enemies_dir+enemy_name)
			#var enemy_inst = enemy_scene.instantiate()
			#enemy_inst.global_position = position
			#debug purposes
			print(file_name + " is spawned! At " + str(position))
			c_a_t.print_message(file_name.get_basename() + " is spawned at " + str(position))
	else:
		c_a_t.print_message(file_name.get_basename() + " doesn't exist as an Scene")
		c_a_t.print_message("The dev needs to change the file name or find the the right place for the enemy. IDK")

func dir_contents(path):
	var dir = DirAccess.open(path)
	print("This path is " + path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.get_extension() == "tscn":
				print("Found Scene: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
