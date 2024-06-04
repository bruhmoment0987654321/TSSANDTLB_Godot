extends CharacterBody2D

@onready var sprite = $Sprite
@onready var flash_timer = $"Flash Timer"
@onready var wall_check = $"Wall Check"
@onready var wall_check_2 = $"Wall Check2"
@onready var wall_check_3 = $"Wall Check3"
@onready var collider = $Collider
@onready var visible_on_screen_notifier_2d = $VisibleOnScreenNotifier2D
@onready var smoke_particle = $"Smoke Particle"
@onready var death_timer = $"Death Timer"
@onready var hurtbox = $EnemyArea/Hurtbox

enum STATE {NORM,DEAD,}

var state = STATE.NORM

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export_group("Movement")
@export var speed = -80
@export var min_launch_x = 200
@export var max_launch_x = 500
@export var min_launch_y = -300
@export var max_launch_y = -600

@export_group("Health")
@export var health = 100

@export_group("Visuals")
@export var flash_time_amount = 0.1
@export var death_time_amount = 2.0

var facing_right = false
var flashing = false

func _ready():
	sprite.play("fly")

func _physics_process(delta):
	if state == STATE.NORM:
		if wall_check.is_colliding() or wall_check_2.is_colliding() or wall_check_3.is_colliding():
			flip()
		velocity.x = speed
		
		if health <= 0:
			dashed()
		
		if flashing and flash_timer.time_left > 0.0:
			sprite.material.set_shader_parameter("flash_modifier",1)
		else:
			sprite.material.set_shader_parameter("flash_modifier",0)
		move_and_slide()
	if state == STATE.DEAD:
		sprite.material.set_shader_parameter("flash_modifier",0)
		smoke_particle.emitting = true
		collider.disabled = true
		hurtbox.disabled = true
		velocity.y += gravity*delta
		move_and_slide()
		
		await visible_on_screen_notifier_2d.screen_exited
		death_timer.start(death_time_amount)

func damaged(damage):
	flashing = true
	flash_timer.start(flash_time_amount)
	health -= damage

func flip():
	facing_right = !facing_right
	scale.x = abs(scale.x) * -1
	
	if facing_right:
		speed = abs(speed)
	else:
		speed = abs(speed) * -1

func launched():
	velocity.x = randf_range(min_launch_x,max_launch_x)
	velocity.y = randf_range(min_launch_y,max_launch_y)
	sprite.play("dead")
	if velocity.x > 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func dashed():
	launched()
	state = STATE.DEAD

func _on_flash_timer_timeout():
	flashing = false

func _on_death_timer_timeout():
	dead()

func dead():
	queue_free()
