extends CharacterBody2D
@export_group("Movement Data")
@export var movement_data : PlayerMovementData

#putting other nodes in variables 
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var dash_timer = $DashTimer
#slime player state
enum STATE{NORMAL,DASH,DEAD}
var player_state = STATE.NORMAL
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#dash variables
@export_group("Dashing") 
#having the player dash or not?
@export var player_dash = true
@export var dash_distance = 60
@export var dash_time = 0.2
@export var max_dash_amount = 2
var dash_amount = max_dash_amount
var dash_direction = Vector2() #get direciton we'll dash in
var dashsp = 0

func _physics_process(delta):
	if player_state == STATE.NORMAL:
		apply_gravity(delta)
		handle_jump()
		handle_dash()
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
			
	if player_state == STATE.DASH:
		if dash_timer.time_left > 0.0:
			velocity = dash_direction*dashsp
		else:
			dash_amount -= 1
			player_state = STATE.NORMAL
		move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity* movement_data.gravity_scale * delta

func handle_jump():
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = movement_data.jump_velocity
	if not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < movement_data.jump_velocity/3:
			velocity.y = movement_data.jump_velocity/3

func handle_dash():
	if Input.is_action_just_pressed("dash") and dash_amount > 0:
		dash_direction = get_dir_from_input()
		dashsp = dash_distance/dash_time
		dash_timer.start(dash_time)
		player_state = STATE.DASH

func handle_acceleration(input_axis,delta):
	var _walk_multiplied = 1
	if movement_data.running:
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
	if dash_amount < 0:
		animated_sprite_2d.modulate = Color(255,138,255)
	else:
		animated_sprite_2d.modulate= Color.WHITE
	if input_axis :
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("walk")
	else:
		animated_sprite_2d.play("idle")
	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite_2d.play("jump")
		else:
			animated_sprite_2d.play("fall")

func get_dir_from_input():
	var move_dir = Vector2()
	move_dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_dir.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	move_dir = move_dir.limit_length(1)
	
	if move_dir == Vector2(0,0):
		if animated_sprite_2d.flip_h:
			move_dir.x = -1
		else:
			move_dir.x = 1
	return move_dir
