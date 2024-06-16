extends CharacterBody2D

#putting other nodes in variables 
@onready var sprite = $Slime
#particles
@onready var dash_particles = $Particles/"Dash Particles"
@onready var landing_particle = $"Particles/Landing Particle"
@onready var death_animation = $"Particles/Death Animation"

#collision boxes
@onready var collider = $Collider
@onready var enemy_collider = $"Other Collisions/EnemyDetector/CollisionShape2D"
@onready var hitbox = $"Other Collisions/HazardDetector/Hitbox"
#timers
@onready var jump_dash_timer = $"Timers/Jump Dash Timer"
@onready var jump_buffer_timer = $"Timers/Jump Buffer Timer"
@onready var coyote_jump_timer = $"Timers/Coyote Jump Timer"
@onready var dash_timer = $"Timers/Dash Timer"
@onready var death_timer = $"Timers/Death Timer"
#ledge pushing raycast
@onready var pushing_right_raycast = $"Ledge Pushing/Pushing Right Raycast"
@onready var pushing_right_raycast_2 = $"Ledge Pushing/Pushing Right Raycast2"
@onready var pushing_left_raycast = $"Ledge Pushing/Pushing Left Raycast"
@onready var pushing_left_raycast_2 = $"Ledge Pushing/Pushing Left Raycast2"
#areas
@onready var danger_area = $"Other Collisions/Danger Area"
#others
@onready var cam = $"../Cam"
@onready var player_position = $"Player Position"


#getting position for spawn point
@onready var spawn_position = global_position

var prev_spawn_position = Vector2(0,0)

@export_group("Movement")
##This is where you place the movement data for the player. The variables are pretty self-explanitory
@export var movement_data : PlayerMovementData

@export_group("Visuals")
@export var squish_speed = 3
@export var jump_squish : Vector2 = Vector2(0.7,1.3)
@export var landing_squish : Vector2 = Vector2(1.3,0.7)
@export var dash_squish_up : Vector2 = Vector2(0.5,1.5)
@export var dash_squish_right : Vector2 = Vector2(1.5,0.5)
@export var duck_squish_press : Vector2 = Vector2(1.8,0.3)
@export var duck_squish_release : Vector2 = Vector2(0.8,1.2)
#squash and stretch
var was_airborne = false

#slime player state
enum STATE{NORMAL,DASH,DEAD,NO_CLIP,}
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
##the color showing there is only one dash left
@export_color_no_alpha var dash_color_almost_running_out = Color.WHITE
##the color that shows there isn't any dash
@export_color_no_alpha var dash_color_running_out = Color.WHITE
##how many particles are created when dashing
@export var dash_particle_amount = 200
##how long the time stop duration goes when you start to dash
@export var dash_hit_stop_duration = 0.1
##the speed of time when dashing into an enemy
@export var dash_hit_stop_timescale = 0.03

@export_group("Hit Stop")
##duration (in seconds) of the time stop 
@export var hit_stop_duration = 0.5
##the speed of time
@export var hit_stop_time_scale = 0.05
##how much the camera zooms in during the hitstop
@export var hit_stop_camera_zoom = Vector2(0.5,0.5)
##the speed the camera goes when zoomming in
@export var hit_scale_zoom_speed = 0.1

@export_group("Death")
@export var death_time_amount = 5.0
@export var death_hit_stop_duration = 1.0
@export var death_zoom_amount = Vector2(2,2)

var checkpoint_has_reset = false
var stop_checking_checkpoints = false

@export_group("CHEATS")
##speed for no_clip movement
@export var no_clip_speed = 100

var jump_dash = false
var ghost_trail = preload("res://Player/ghost_trail.tscn")
var dash_time_less = dash_time - 0.01 #used so the dash doesnt happen more than once during dash
var dash_direction = Vector2() #get direciton we'll dash in
var dash_energy = 0
var dashsp = 0

func _ready():
	Global.dash_amount = max_dash_amount
	SignalBus.emit_set_camera_target(self)
func _physics_process(delta):
	if player_state == STATE.NORMAL:
		collider.disabled = false
		hitbox.disabled = false
		enemy_collider.disabled = false
		
		apply_gravity(delta)
		handle_jump()
		handle_dash()
		jump_dashing()
		
		var input_axis = Input.get_axis("left", "right")
		handle_acceleration(input_axis,delta)
		apply_friction(input_axis,delta)
		apply_air_resistance(input_axis,delta)
		ledge_pushing()
		update_animation(input_axis,delta)
		var was_on_floor_coyote = is_on_floor()
		move_and_slide()
		
		var just_left_ledge = was_on_floor_coyote and not is_on_floor() and velocity.y >= 0
		if just_left_ledge:
			coyote_jump_timer.start(movement_data.coyote_time)
			
		checkpoint_reset()
	if player_state == STATE.DASH:
		if dash_energy > 0:
			is_dashing(delta)
			var input_axis = Input.get_axis("left", "right")
			handle_acceleration(input_axis,delta)
		else:
			ending_dash()
		ledge_pushing()
		move_and_slide()
	if player_state == STATE.DEAD:
		death()
	if player_state == STATE.NO_CLIP:
		hitbox.disabled = true
		enemy_collider.disabled = true
		collider.disabled = true
		move_free()
		move_and_slide()

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
	dash_particles.emitting = false
	velocity = Vector2(0,0)
	if jump_dash:
		jump_dash_timer.start(jump_dash_time)
	player_state = STATE.NORMAL

func handle_acceleration(input_axis,delta):
	var _walk_multiplied = 1
	
	if Input.is_action_pressed("down"):
		_walk_multiplied = movement_data.duck_walk_speed_mutiplied
	
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
	elif is_on_floor():
			dash_particles.emitting = false
			after_jump_dash = false

func ledge_pushing():
	var to_push_left = pushing_left_raycast.is_colliding() and pushing_left_raycast_2.is_colliding()\
	and not pushing_right_raycast.is_colliding() and not pushing_right_raycast_2.is_colliding()
	
	var to_push_right = not pushing_left_raycast.is_colliding() and not pushing_left_raycast_2.is_colliding()\
	and pushing_right_raycast.is_colliding() and pushing_right_raycast_2.is_colliding() 
	
	if to_push_left:
		global_position.x -= movement_data.ledge_push_distance
	elif to_push_right:
		global_position.x += movement_data.ledge_push_distance

func update_animation(input_axis,delta):
	match Global.dash_amount:
		0:
			sprite.modulate = dash_color_running_out
		1:
			sprite.modulate = dash_color_almost_running_out
		2:
			sprite.modulate = Color.WHITE
	if is_on_floor():
		if was_airborne:
			was_airborne = false
			#squishy
			turn_squishy(landing_squish.x,landing_squish.y)
			#landing particle
			landing_particle.emitting = true
	else:
		landing_particle.emitting = false
		was_airborne = true
	
	if input_axis :
		if input_axis:
			sprite.flip_h = (input_axis < 0)
		if Input.is_action_pressed("down"):
			sprite.play("Duck Walk")
		else:
			sprite.play("Walk")
	else:
		if is_on_floor():
			if Input.is_action_just_pressed("down"):
				turn_squishy(duck_squish_press.x,duck_squish_press.y)
			if Input.is_action_just_released("down"):
				turn_squishy(duck_squish_release.x,duck_squish_release.y)
			if Input.is_action_pressed("down"):
				sprite.play("SQUISH")
			else:
				sprite.play("Idle")
	
	if not is_on_floor():
		if velocity.y < 0:
			sprite.play("Jump")
		else:
			sprite.play("Fall")
	squash_and_stretch(delta)

func death():
	await death_timer.timeout
	global_position = spawn_position
	Global.dash_amount = max_dash_amount
	player_state = STATE.NORMAL
	death_animation.emitting = false
	velocity = Vector2(0,0)
	stop_checking_checkpoints = false
	enemy_collider.disabled = false

func turn_squishy(x,y):
	sprite.scale = Vector2(x,y)

func squash_and_stretch(delta):
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

func hit_stop(time_scale,duration,delta, zoom_amount = Vector2(1,1), death = false):
	Engine.time_scale = time_scale
	cam.zoom.x = move_toward(zoom_amount.x,1,hit_scale_zoom_speed*delta)
	cam.zoom.y = move_toward(zoom_amount.y,1,hit_scale_zoom_speed*delta)
	var timer = get_tree().create_timer(duration*time_scale)
	
	await timer.timeout
	Engine.time_scale = 1
	cam.zoom.x = move_toward(1,zoom_amount.x,hit_scale_zoom_speed*delta)
	cam.zoom.y = move_toward(1,zoom_amount.y,hit_scale_zoom_speed*delta)
	
	if death:
		death_timer.start(death_time_amount)
		death_animation.emitting = true
		cam.apply_shake(5)
		sprite.play("Death")
		Global.death_count += 1
		player_state = STATE.DEAD

func no_clip():
	if player_state != STATE.NO_CLIP:
		player_state = STATE.NO_CLIP
	else:
		player_state = STATE.NORMAL

func move_free():
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * no_clip_speed

func checkpoint_reset():
	if not stop_checking_checkpoints and not danger_area.has_overlapping_areas():
		if not is_on_floor():
			checkpoint_has_reset = false
		elif not checkpoint_has_reset:
			prev_spawn_position = spawn_position
			spawn_position = player_position.global_position
			checkpoint_has_reset = true

func _on_hazard_detector_area_entered(area):
	stop_checking_checkpoints = true
	print(str(global_position.x) + ", " + str(global_position.y))
	hit_stop(hit_stop_time_scale,1,get_process_delta_time(),death_zoom_amount,true)

func _on_enemy_detector_area_entered(area):
	stop_checking_checkpoints = true
	if player_state == STATE.DASH or jump_dash or after_jump_dash:
		area.get_parent().dashed()
		hit_stop(dash_hit_stop_timescale,hit_stop_duration,get_process_delta_time(),hit_stop_camera_zoom)
	else:
		print(str(global_position.x) + ", " + str(global_position.y))
		hit_stop(hit_stop_time_scale,1,get_process_delta_time(),death_zoom_amount,true)

