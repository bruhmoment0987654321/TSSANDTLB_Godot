extends CharacterBody2D

@onready var ray_cast_2d = $"Ground Check"
@onready var wall_check = $"Wall Check"
@onready var sprite = $Sprite

@export var speed = 60
@export var health = 100

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var facing_right = false

func _ready():
	sprite.play("walk")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity*delta
	
	if !ray_cast_2d.is_colliding() && is_on_floor():
		flip()
	if wall_check.is_colliding():
		flip()
	
	if health <= 0:
		dead()
	
	velocity.x = speed
	move_and_slide()

func damaged(damage):
	health -= damage

func flip():
	facing_right = !facing_right
	scale.x = abs(scale.x) * -1
	
	if facing_right:
		speed = abs(speed)* -1
	else:
		speed = abs(speed)

func dead():
	queue_free()
