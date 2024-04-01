extends Sprite2D
@export var position_lag_speed = 0.5
@export var gun_location = Vector2(0,-16)
@export var fire_rate = 0.2
@export var bullet_speed = 1000
@onready var marker = $Marker2D
var can_fire = true
var bullet = preload("res://Player/The Boy/Scenes/bullet.tscn")
func _ready():
	top_level = true

func _physics_process(delta):
	var mouse_pos = get_global_mouse_position()
	position = lerp(position,get_parent().position+gun_location,position_lag_speed)
	look_at(mouse_pos)
	shoot()
func shoot():
	if Input.is_action_just_pressed("shoot") and can_fire and Global.ammo > 0:
		var b = bullet.instantiate()
		b.rotation = rotation
		b.speed = bullet_speed
		b.global_position = marker.global_position
		add_child(b)
		can_fire = false
		await get_tree().create_timer(fire_rate).timeout
		can_fire = true
		

