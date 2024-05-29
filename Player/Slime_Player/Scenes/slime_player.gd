extends CharacterBody2D

#putting other nodes in variables 
@onready var sprite = $Slime
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var dash_timer = $DashTimer
@onready var dash_particles = $DashParticles
@onready var jump_buffer_timer = $JumpBufferTimer
@onready var jump_dash_timer = $JumpDashTimer
@onready var cam = $"../Cam"
@onready var player_position = $"Player Position"
@onready var killer_timer = $KillerTimer

#getting position for spawn point
@onready var spawn_position = global_position

@export_group("Movement Data")
##This is where you place the movement data for the player. The variables are pretty self-explanitory
@export var movement_data : PlayerMovementData

@export_group("Visuals")
@export var squish_speed = 3
@export var jump_squish : Vector2 = Vector2(0.7,1.3)
@export var landing_squish : Vector2 = Vector2(1.3,0.7)
@export var dash_squish_up : Vector2 = Vector2(0.5,1.5)
@export var dash_squish_right : Vector2 = Vector2(1.5,0.5)

#squash and stretch
var was_airborne = false

#slime player state
enum STATE{NORMAL,DASH,DEAD}
var player_state = STATE.NORMAL
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#dash variables
@export_group("Dashing") 
##having the player dash or not?
@export var player_dash = true
##the distance the dash will go
@export var dash_distance = 100
##the amount of time the dash lasts for
@export var dash_time = 0.2
##how many times the player can dash for until he isn't able to.
@export var max_dash_amount = 2
##the amount of buffer time that the player has that makes him invincible
@export var overkill_length = 1.0

@export var dash_sound_FX = preload("res://Music/dash (new).wav")

@export_group("Jump-Dash")
##how long the jump dash lasts
@export var jump_dash_time = 0.1
##the distance you go during your jump dash. 
@export var jump_dash_distance = 200
##the height you go during you jump dash
@export var jump_dash_height = -200
##the amount of decreased air resistance when you press left or right
@export var jump_dash_friction_decrease_amount = 0.9

var jump_dash_friction_decrease = 1
var after_jump_dash = false

@export_group("Dash Visuals")
##the color the player looks like whenever the dash runs out
@export var dash_color_running_out = Color.WHITE
##how many particles are created when dashing
@export var dash_particle_amount = 200

var jump_dash = false
var ghost_trail = preload("res://Player/ghost_trail.tscn")
var dash_time_less = dash_time - 0.01 #used so the dash doesnt happen more than once during dash
var dash_direction = Vector2() #get direciton we'll dash in
var dash_energy = 0
var dashsp = 0

func _ready():
	Global.dash_amount = max_dash_amount

func _physics_process(delta):
	if player_state == STATE.NORMAL:
		apply_gravity(delta)
		handle_jump()
		handle_dash()
		jump_dashing()
		var input_axis = Input.get_axis("left", "right")
		handle_acceleration(input_axis,delta)
		apply_friction(input_axis,delta)
		apply_air_resistance(input_axis,delta)
		update_animation(input_axis,delta)
		var was_on_floor = is_on_floor()
		move_and_slide()
		var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
		if just_left_ledge:
			coyote_jump_timer.start(movement_data.coyote_time)
	if player_state == STATE.DASH:
		if dash_energy > 0:
			is_dashing(delta)
		else:
			ending_dash()
		move_and_slide()
	if player_state == STATE.DEAD:
		death()

func apply_gravity(delta):
	if not is_on_floor() and velocity.y < 0:
		velocity.y += gravity* movement_data.gravity_scale * delta
	else:
		velocity.y += gravity* movement_data.gravity_scale*movement_data.gravity_acceleration * delta

func handle_jump():
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump") or jump_buffer_timer.time_left > 0.0:
			velocity.y = movement_data.jump_velocity
			turn_squishy(jump_squish.x,jump_squish.y)
	elif not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < movement_data.jump_velocity/3:
			velocity.y = movement_data.jump_velocity/3
	elif Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start(movement_data.jump_buffer)

func handle_dash():
	if is_on_floor() and Global.dash_amount < max_dash_amount:
		Global.dash_amount = max_dash_amount
	if Input.is_action_just_pressed("dash") and Global.dash_amount > 0:
		dash_direction = get_dir_from_input()
		dashsp = dash_distance/dash_time
		dash_energy = dash_distance
		player_state = STATE.DASH
		AudioManager.play_FX(dash_sound_FX)
		cam.apply_shake(4)

func is_dashing(delta):
	dash_energy -= dashsp*delta
	velocity = dash_direction*dashsp
	dash_particles.emitting = true
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		jump_dash = true
		ending_dash()
	if dash_timer.time_left > 0.0 and Global.dash_amount > 0 and Input.is_action_just_pressed("dash") and dash_timer.time_left < dash_time_less:
		Global.dash_amount -= 1
		dash_particles.emitting = false
		dash_timer.start(dash_time)
	var dash_node = ghost_trail.instantiate()
	dash_node.texture = sprite.sprite_frames.get_frame_texture(sprite.animation,sprite.frame)
	dash_node.global_position = global_position+Vector2(0,-16)
	dash_node.flip_h = sprite.flip_h
	get_parent().add_child(dash_node)

func ending_dash():
	Global.dash_amount -= 1
	velocity = Vector2(0,0)
	dash_particles.emitting = false
	if jump_dash:
		jump_dash_timer.start(jump_dash_time)
	killer_timer.start(overkill_length)
	player_state = STATE.NORMAL

func handle_acceleration(input_axis,delta):
	var _walk_multiplied = 1
	if Input.is_action_pressed("run"):
		_walk_multiplied = movement_data.run_multiplier
	if input_axis: #if direction != 0
		if after_jump_dash: 
			jump_dash_friction_decrease = jump_dash_friction_decrease_amount
		else:
			jump_dash_friction_decrease = 1
			velocity.x = move_toward(velocity.x,movement_data.hspeed*input_axis*_walk_multiplied,movement_data.acceleration*delta)

func apply_friction(input_axis,delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction*delta)

func apply_air_resistance(input_axis,delta):
	if jump_dash: return
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x,0,movement_data.air_resistance*jump_dash_friction_decrease*delta)

func jump_dashing():
	if jump_dash:
		dash_particles.emitting = true
		if not sprite.flip_h: velocity.x = jump_dash_distance
		else: velocity.x = jump_dash_distance * -1
		velocity.y = jump_dash_height
		var dash_node = ghost_trail.instantiate()
		dash_node.texture = sprite.sprite_frames.get_frame_texture(sprite.animation,sprite.frame)
		dash_node.global_position = global_position+Vector2(0,-16)
		dash_node.flip_h = sprite.flip_h
		get_parent().add_child(dash_node)
		if jump_dash_timer.time_left == 0.0: 
			jump_dash = false
			after_jump_dash = true
	else:
		dash_particles.emitting = false
		if is_on_floor():
			after_jump_dash = false

func update_animation(input_axis,delta):
	if Global.dash_amount == 0:
		sprite.modulate = dash_color_running_out
	else:
		sprite.modulate = Color.WHITE
	if input_axis :
		sprite.flip_h = (input_axis < 0)
		sprite.play("Walk")
	else:
		sprite.play("Idle")
	if not is_on_floor():
		if velocity.y < 0:
			sprite.play("Jump")
		else:
			sprite.play("Fall")
	squash_and_stretch(delta)

func death():
	Global.death_count += 1
	global_position = spawn_position
	Global.dash_amount = max_dash_amount
	player_state = STATE.NORMAL
	velocity = Vector2(0,0)
	cam.apply_shake(5)
	print(str(global_position.x) + ", " + str(global_position.y))

func turn_squishy(x,y):
	sprite.scale = Vector2(x,y)
	
func squash_and_stretch(delta):
	if is_on_floor():
		if was_airborne:
			was_airborne = false
			#squishy
			turn_squishy(landing_squish.x,landing_squish.y)
	else:
		was_airborne = true
	
	sprite.scale.x = move_toward(sprite.scale.x,1,squish_speed*delta)
	sprite.scale.y = move_toward(sprite.scale.y,1,squish_speed*delta)

func get_dir_from_input():
	var move_dir = Vector2()
	move_dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_dir.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	move_dir = move_dir.limit_length(1)
	if move_dir == Vector2(0,0):
		if sprite.flip_h:
			move_dir.x = -1
		else:
			move_dir.x = 1
	return move_dir

func _on_hazard_detector_area_entered(area):
	player_state = STATE.DEAD

func _on_enemy_detector_area_entered(area):
	if player_state == STATE.DASH or jump_dash or killer_timer.time_left > 0.0:
		area.get_parent().dead()
	else:
		player_state = STATE.DEAD

func _on_checkpoint_detector_area_entered(area):
	if area.is_in_group("Checkpoint_1"):
		spawn_position = area.owner.check_point
		print("Hit Checkpoint_1")
	if area.is_in_group("Checkpoint_2"):
		spawn_position = area.owner.check_point_2
		print("Hit Checkpoint_2")
	if area.is_in_group("Checkpoint_3"):
		spawn_position = area.owner.check_point_3
		print("Hit Checkpoint_3")
