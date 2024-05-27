extends Area2D

@export var speed = 1000
@export var damage = 10

func _ready():
	top_level = true

func _process(delta):
	position += (Vector2.RIGHT*speed).rotated(rotation)*delta

func _physics_process(delta):
	await get_tree().create_timer(0.01).timeout
	set_physics_process(false)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body):
	queue_free()


func _on_enemy_detector_area_entered(area):
	area.get_parent().damaged(damage)
	queue_free()
