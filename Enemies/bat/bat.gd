extends CharacterBody2D

@onready var sprite = $Sprite
@onready var wall_check = $"Wall Check"
@onready var wall_check_2 = $"Wall Check2"
@onready var wall_check_3 = $"Wall Check3"

@export var speed = -80
@export var health = 100

var facing_right = false

func _ready():
	sprite.play("fly")

func _physics_process(delta):
	if wall_check.is_colliding() or wall_check_2.is_colliding() or wall_check_3.is_colliding():
		flip()
	velocity.x = speed
	
	if health <= 0:
		dead()
	
	move_and_slide()

func damaged(damage):
	health -= damage


func flip():
	facing_right = !facing_right
	scale.x = abs(scale.x) * -1
	
	if facing_right:
		speed = abs(speed)
	else:
		speed = abs(speed) * -1

func dead():
	queue_free()