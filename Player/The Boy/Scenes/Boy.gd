extends CharacterBody2D

#other
@onready var sprite = $AnimatedSprite2D
@onready var cam = $"../Cam"
@onready var gun = $Gun
@onready var player_position = $"Player Position"
#collisions
@onready var hazard_hitbox = $"Collisions/HazardDetector/Hazard Hitbox"
@onready var enemy_collider = $Collisions/EnemyDetector/CollisionShape2D
@onready var collider = $Collider
#timers
@onready var knockback_timer = $Timers/KnockbackTimer
@onready var fire_rate_timer = $Timers/FireRateTimer
@onready var coyote_jump_timer = $Timers/CoyoteJumpTimer
@onready var jump_buffer_timer = $Timers/JumpBufferTimer
@onready var death_timer = $"Timers/Death Timer"
#particles
@onready var soda_blast_particles = $"Particles/Soda Blast Particles"
@onready var death_animation = $"Particles/Death Animation"
@onready var landing_particle = $"Particles/Landing Particle"
#ledge pushing raycast
@onready var pushing_right_raycast = $"Ledge Pushing/Pushing Right Raycast"
@onready var pushing_right_raycast_2 = $"Ledge Pushing/Pushing Right Raycast2"
@onready var pushing_left_raycast = $"Ledge Pushing/Pushing Left Raycast"
@onready var pushing_left_raycast_2 = $"Ledge Pushing/Pushing Left Raycast2"
#areas 
@onready var danger_area = $"Collisions/Danger Area"
#getting position for spawn point
@onready var spawn_position = global_position

var prev_spawn_position = Vector2(0,0)

##This is where you place the movement data for the player, The variables are pretty self-explanitory
@export var movement_data : PlayerMovementData

enum STATE{NORMAL,GUN,DEAD,NO_CLIP,}

var player_state = STATE.NORMAL

@export_group("Visuals")
@export var squish_speed = 3
@export var jump_squish : Vector2 = Vector2(0.7,1.3)
@export var landing_squish : Vector2 = Vector2(1.3,0.7)
@export var shoot_squish : Vector2 = Vector2(0.6,1.4)
@export var duck_squish_press : Vector2 = Vector2(1.8,0.3)
@export var duck_squish_release : Vector2 = Vector2(0.8,1.2)

@export_group("Sound FX")
@export var shoot_sound_FX = preload("res://Music/shoot.wav")

#squash and stretch
var was_airborne = false

@export_group("Shooting")
##the distance the player will be shot back at whenever shooting
@export var launch_power = 1000
##the original launch power when the ammo_used is less than the amount you have.
@export var launch_power_decrease_multiplied = 0.5
##the opposite of launch_power_decrease_mulitiplied. Used when you hold run and shoot
@export var increased_launch_power_multiplied = 1.5
##the recharge speed of the ammo
@export var charge_rate = 20
##when the boy is on the ground, it should charge the ammo faster
@export var charge_rate_multiplied = 1.2
##how much ammo is consumed during shooting
@export var ammo_used = 20
##the increase multiplier when using the blast
@export var increased_ammo_cost = 2
##the maximum amount of ammo the gun can have
@export var max_ammo = 100

#checking if you are in the gun_jump state
var gun_jumping = false

@export_group("Hit Stop")
@export var hit_scale_zoom_speed = 0.5
@export var hit_stop_time_scale = 0.5

@export_group("Death")
@export var death_time_amount = 2.0
@export var death_zoom_amount = Vector2(1.7,1.7)

var checkpoint_has_reset = false
var stop_checking_checkpoints = false
@export_group("CHEATS")
##speed of no_clip movement
@export var no_clip_speed = 300

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	Global.ammo = max_ammo
	Global.emit_set_camera_target(self)

func _physics_process(delta):
	if not is_on_floor(): 
		Global.ammo = min(Global.ammo + (delta * charge_rate), 100.0)
	else:
		Global.ammo = min(Global.ammo + (delta * charge_rate*charge_rate_multiplied), 100.0)
	if player_state == STATE.NORMAL:
		collider.disabled = false
		hazard_hitbox.disabled = false
		enemy_collider.disabled = false
		apply_gravity(delta)
		handle_jump()
		var input_axis = Input.get_axis("left", "right")
		handle_acceleration(input_axis,delta)
		apply_friction(input_axis,delta)
		apply_air_resistance(input_axis,delta)
		gun_jump()
		ledge_pushing()
		update_animation(input_axis,delta)
		var was_on_floor = is_on_floor()
		move_and_slide()
		var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
		if just_left_ledge:
			coyote_jump_timer.start()
		checkpoint_reset()
	if player_state == STATE.DEAD:
		death()
	if player_state == STATE.NO_CLIP:
		collider.disabled = true
		hazard_hitbox.disabled = true
		enemy_collider.disabled = true
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

func gun_jump():
	var power = launch_power
	var ammo_cost = ammo_used
	if Input.is_action_just_pressed("shoot") and Global.ammo > 0:
		if Global.ammo < ammo_cost: power *= launch_power_decrease_multiplied
		
		var angle = gun.rotation+deg_to_rad(180)
		
		velocity = Vector2(1,0).rotated(angle)*power
		
		Global.ammo -= ammo_cost
		
		turn_squishy(shoot_squish.x,shoot_squish.y)
		AudioManager.play_FX(shoot_sound_FX)
		cam.apply_shake(3)
		gun_jumping = true
	elif Input.is_action_just_pressed("gun_jump") and Global.ammo > 0:
		if Global.ammo < ammo_cost: power *= launch_power_decrease_multiplied
		
		
		var angle = gun.rotation+deg_to_rad(180)
		
		power *= increased_launch_power_multiplied
		ammo_cost *= increased_ammo_cost
		
		velocity = Vector2(1,0).rotated(angle)*power
		
		Global.ammo -= ammo_cost
		
		soda_blast_particles.direction = Vector2.from_angle(gun.rotation)
		soda_blast_particles.emitting = true
		turn_squishy(shoot_squish.x,shoot_squish.y)
		AudioManager.play_FX(shoot_sound_FX,5)
		cam.apply_shake(5)
		gun_jumping = true
	if gun_jumping and is_on_floor():
		gun_jumping = true

func handle_acceleration(input_axis,delta):
	var _walk_multiplied = 1
	
	if Input.is_action_pressed("down"):
		_walk_multiplied = movement_data.duck_walk_speed_mutiplied
	
	if input_axis: #if direction != 0
		velocity.x = move_toward(velocity.x,movement_data.hspeed*input_axis*_walk_multiplied,movement_data.acceleration*delta)

func apply_friction(input_axis,delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction*delta)

func apply_air_resistance(input_axis,delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x,0,movement_data.air_resistance*delta)

func ledge_pushing():
	var to_push_left = pushing_left_raycast.is_colliding() and pushing_left_raycast_2.is_colliding()\
	and not pushing_right_raycast.is_colliding() and not pushing_right_raycast_2.is_colliding()
	
	var to_push_right = not pushing_left_raycast.is_colliding() and not pushing_left_raycast_2.is_colliding()\
	and pushing_right_raycast.is_colliding() and pushing_right_raycast_2.is_colliding()
	
	if not gun_jumping:
		if to_push_left:
			global_position.x -= movement_data.ledge_push_distance
		elif to_push_right:
			global_position.x += movement_data.ledge_push_distance

func update_animation(input_axis,delta):
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
	
	if input_axis:
		sprite.flip_h = (input_axis < 0)
		if Input.is_action_pressed("down"):
			sprite.play("duck_walk")
		else:
			sprite.play("walk")
	else:
		if is_on_floor():
			if Input.is_action_just_pressed("down"):
				turn_squishy(duck_squish_press.x,duck_squish_press.y)
			if Input.is_action_just_released("down"):
				turn_squishy(duck_squish_release.x,duck_squish_release.y)
			if Input.is_action_pressed("down"):
				sprite.play("SQUISH")
			else:
				sprite.play("idle")
	
	if not is_on_floor():
		if velocity.y < 0:
			sprite.play("jump")
		else:
			sprite.play("fall")
	squash_and_stretch(delta)

func death():
	hazard_hitbox.disabled = true
	enemy_collider.disabled = true
	
	await death_timer.timeout
	global_position = spawn_position
	player_state = STATE.NORMAL
	gun.visible = true
	death_animation.emitting = false
	stop_checking_checkpoints = false
	enemy_collider.disabled = false
	
	Global.ammo = max_ammo
	velocity = Vector2(0,0)
	cam.apply_shake(5)
	gun.global_position = global_position

func turn_squishy(x,y):
	sprite.scale = Vector2(x,y)

func squash_and_stretch(delta):
	sprite.scale.x = move_toward(sprite.scale.x,1,squish_speed*delta)
	sprite.scale.y = move_toward(sprite.scale.y,1,squish_speed*delta)

func no_clip():
	if player_state != STATE.NO_CLIP:
		player_state = STATE.NO_CLIP
	else:
		player_state = STATE.NORMAL

func move_free():
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * no_clip_speed

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
		sprite.play("death")
		gun.visible = false
		Global.death_count += 1
		player_state = STATE.DEAD

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
	print(str(global_position.x) + ", " + str(global_position.y))
	hit_stop(hit_stop_time_scale,1,get_process_delta_time(),death_zoom_amount,true)
