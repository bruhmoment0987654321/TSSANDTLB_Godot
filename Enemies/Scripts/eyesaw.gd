extends Node2D

@onready var saw = $Saw
@onready var eye = $Eye

@export var moving_up = false
@export var moving_right = false
@export var speed = 50
@export var left_most_point = 0
@export var right_most_point = 100
@export var lowest_point = 0
@export var highest_point = 100

var facing_right = false
var facing_up = false
var looking = false

# Called when the node enters the scene tree for the first time.
func _ready():
	saw.play("idle")

func _process(delta):
	for player in get_tree().get_nodes_in_group("Player"):
		var rad = global_position.angle_to_point(player.global_position)
		eye.frame = -(rad_to_deg(rad))/45

func _physics_process(delta):
	if moving_right:
		if position.x < left_most_point or position.x > right_most_point:
			flip_left()
		position.x += speed*delta
	if moving_up:
		if position.y < lowest_point or position.y > highest_point:
			flip_up()
			
		position.y += speed*delta

func _on_player_detection_body_entered(body):
	saw.play("spin")
	for player in get_tree().get_nodes_in_group("Player"):
		var rad = global_position.angle_to_point(player.global_position)
		eye.frame = (rad_to_deg(rad)+180/45)

func _on_player_detection_body_exited(body):
	saw.play("idle")

func flip_up():
	facing_up = !facing_up
	if facing_up:
		speed = abs(speed)*-1
	else:
		speed = abs(speed)

func flip_left():
	facing_right = !facing_right
	if facing_right:
		speed = abs(speed)*-1
	else:
		speed = abs(speed)
