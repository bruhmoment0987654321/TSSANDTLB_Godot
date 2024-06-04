extends CharacterBody2D

@onready var ray_cast_2d = $"Ground Check"
@onready var wall_check = $"Wall Check"
@onready var sprite = $Sprite
@onready var flash_timer = $"Flash Timer"
@onready var visible_on_screen_notifier_2d = $VisibleOnScreenNotifier2D
@onready var collider = $Collider
@onready var collision_shape_2d = $EnemyArea/CollisionShape2D
@onready var death_timer = $"Death Timer"
@onready var smoke_particle = $"Smoke Particle"

enum STATE {NORM,DEAD,}

var state = STATE.NORM

@export var speed = 60
@export var health = 100
@export var flash_time_amount = 0.1
@export var min_launch_x = 200
@export var max_launch_x = 500
@export var min_launch_y = -300
@export var max_launch_y = -600
@export var death_time_amount = 3.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var facing_right = false

var flashing = false

func _ready():
	sprite.play("walk")

func _physics_process(delta):
	if state == STATE.NORM:
		if not is_on_floor():
			velocity.y += gravity*delta
		
		if !ray_cast_2d.is_colliding() && is_on_floor():
			flip()
		if wall_check.is_colliding():
			flip()
		
		if health <= 0:
			dashed()
		
		velocity.x = speed
		
		if flashing and flash_timer.time_left > 0.0:
			sprite.material.set_shader_parameter("flash_modifier",1)
		else:
			sprite.material.set_shader_parameter("flash_modifier",0)
		
		move_and_slide()
	if state == STATE.DEAD:
		sprite.material.set_shader_parameter("flash_modifier",0)
		velocity.y += gravity*delta
		collider.disabled = true
		collision_shape_2d.disabled = true
		smoke_particle.emitting = true
		move_and_slide()
		
		await visible_on_screen_notifier_2d.screen_exited
		death_timer.start(death_time_amount)

func damaged(damage):
	flashing = true
	flash_timer.start(flash_time_amount)
	health -= damage

func dashed():
	launched()
	state = STATE.DEAD

func flip():
	facing_right = !facing_right
	scale.x = abs(scale.x) * -1
	
	if facing_right:
		speed = abs(speed)* -1
	else:
		speed = abs(speed)

func launched():
	velocity.x = randf_range(min_launch_x,max_launch_x)
	velocity.y = randf_range(min_launch_y,max_launch_y)
	sprite.play("hit")
	if velocity.x > 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func dead():
	queue_free()


func _on_flash_timer_timeout():
	flashing = false


func _on_death_timer_timeout():
	dead()
