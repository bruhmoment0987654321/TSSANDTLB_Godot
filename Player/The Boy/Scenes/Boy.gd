extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var dash_timer = $DashTimer
@onready var fire_rate_timer = $FireRateTimer
@onready var jump_buffer_timer = $JumpBufferTimer
@onready var cam = $"../Cam"
@onready var gun = $Gun
@onready var player_position = $"Player Position"
#getting position for spawn point
@onready var spawn_position = global_position

##This is where you place the movement data for the player, The variables are pretty self-explanitory
@export var movement_data : PlayerMovementData

enum STATE{NORMAL,DEAD}

var player_state = STATE.NORMAL

@export_group("Visuals")
@export var squish_speed = 3
@export var jump_squish : Vector2 = Vector2(0.7,1.3)
@export var landing_squish : Vector2 = Vector2(1.3,0.7)
@export var shoot_squish : Vector2 = Vector2(0.6,1.4)
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
##the increase multiplier when holding run and shoot
@export var increased_ammo_cost = 2
##the maximum amount of ammo the gun can have
@export var max_ammo = 100

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	Global.ammo = max_ammo

func _process(delta):
	if not is_on_floor(): 
		Global.ammo = min(Global.ammo + (delta * charge_rate), 100.0)
	else:
		Global.ammo = min(Global.ammo + (delta * charge_rate*charge_rate_multiplied), 100.0)
	if player_state == STATE.NORMAL:
		apply_gravity(delta)
		handle_jump()
		gun_jump()
		var input_axis = Input.get_axis("left", "right")
		handle_acceleration(input_axis,delta)
		apply_friction(input_axis,delta)
		apply_air_resistance(input_axis,delta)
		update_animation(input_axis,delta)
		var was_on_floor = is_on_floor()
		move_and_slide()
		var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
		if just_left_ledge:
			coyote_jump_timer.start()
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

func gun_jump():
	var power = launch_power
	var ammo_cost = ammo_used
	if Input.is_action_just_pressed("shoot") and Global.ammo > 0:
		Global.ammo -= ammo_cost
		if Global.ammo < ammo_cost: power *= launch_power_decrease_multiplied
		var angle = gun.rotation+deg_to_rad(180)
		velocity = Vector2(1,0).rotated(angle)*power
		turn_squishy(shoot_squish.x,shoot_squish.y)
		AudioManager.play_FX(shoot_sound_FX)
		cam.apply_shake(3)
	elif Input.is_action_just_pressed("gun_jump") and Global.ammo > 0:
		power *= increased_launch_power_multiplied
		AudioManager.play_FX(shoot_sound_FX,5)
		ammo_cost *= increased_ammo_cost
		Global.ammo -= ammo_cost
		if Global.ammo < ammo_cost: power *= launch_power_decrease_multiplied
		var angle = gun.rotation+deg_to_rad(180)
		velocity = Vector2(1,0).rotated(angle)*power
		turn_squishy(shoot_squish.x,shoot_squish.y)
		cam.apply_shake(5)

func handle_acceleration(input_axis,delta):
	var _walk_multiplied = 1
	if Input.is_action_pressed("run"):
		_walk_multiplied = movement_data.run_multiplier
	if input_axis: #if direction != 0
		velocity.x = move_toward(velocity.x,movement_data.hspeed*input_axis*_walk_multiplied,movement_data.acceleration*delta)

func apply_friction(input_axis,delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction*delta)

func apply_air_resistance(input_axis,delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x,0,movement_data.air_resistance*delta)

func update_animation(input_axis,delta):
	if input_axis :
		sprite.flip_h = (input_axis < 0)
		sprite.play("walk")
	else:
		sprite.play("idle")
	if not is_on_floor():
		if velocity.y < 0:
			sprite.play("jump")
		else:
			sprite.play("fall")
	squash_and_stretch(delta)

func death():
	global_position = spawn_position
	Global.death_count += 1
	player_state = STATE.NORMAL
	Global.ammo = max_ammo
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

func _on_hazard_detector_area_entered(area):
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

func _on_enemy_detector_area_entered(area):
	player_state = STATE.DEAD
