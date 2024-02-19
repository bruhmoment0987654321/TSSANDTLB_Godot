extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var dash_timer = $DashTimer
@onready var camera = $Camera
@onready var fire_rate_timer = $FireRateTimer
@onready var gun = $Gun
##This is where you place the movement data for the player, The variables are pretty self-explanitory
@export var movement_data : PlayerMovementData
#getting position for spawn point
@onready var spawn_position = global_position
#camera variables
@export_group("Camera")
##this is used for the distance the player can look down whenever hold DOWN
@export var look_timer_amount = 5
##The camera won't center the player. this changes the placement of the camera based on where the player is
@export var camera_look_offset = Vector2(10,10)
var player_state = STATE.NORMAL
@export_group("Shooting")
##the distance the player will be shot back at whenever shooting
@export var launch_power = 1000
##the recharge speed of the ammo
@export var charge_rate = 20
##how much ammo is consumed during shooting
@export var ammo_used = 20
##the maximum amount of ammo the gun can have
@export var max_ammo = 100
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum STATE{NORMAL,DEAD}

func _ready():
	Global.ammo = max_ammo

func _process(delta):
	Global.ammo = min(Global.ammo + (delta * charge_rate), 100.0)

func _physics_process(delta):
	handle_camera()
	if player_state == STATE.NORMAL:
		apply_gravity(delta)
		handle_jump()
		gun_jump()
		var input_axis = Input.get_axis("left", "right")
		handle_acceleration(input_axis,delta)
		apply_friction(input_axis,delta)
		apply_air_resistance(input_axis,delta)
		update_animation(input_axis)
		var was_on_floor = is_on_floor()
		move_and_slide()
		var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
		if just_left_ledge:
			coyote_jump_timer.start()
	if player_state == STATE.DEAD:
		global_position = spawn_position
		player_state = STATE.NORMAL
func handle_camera():
	pass

func apply_gravity(delta):
	if not is_on_floor() and velocity.y < 0:
		velocity.y += gravity* movement_data.gravity_scale * delta
	else:
		velocity.y += gravity* movement_data.gravity_scale*movement_data.gravity_acceleration * delta

func handle_jump():
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = movement_data.jump_velocity
	elif not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < movement_data.jump_velocity/3:
			velocity.y = movement_data.jump_velocity/3

func gun_jump():
	if Input.is_action_just_pressed("shoot") and Global.ammo > 0:
		print("amount:"+str(Global.ammo))
		Global.ammo -= 20
		print("amount lost:" + str(Global.ammo))
		var angle = gun.rotation+deg_to_rad(180)
		velocity = Vector2(1,0).rotated(angle)*launch_power

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

func update_animation(input_axis):
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

func _on_hazard_detector_area_entered(area):
	player_state = STATE.DEAD
