extends Area2D

@onready var checkpoint_inidicator = $"Checkpoint Inidicator"
@onready var visible_timer = $"Visible Timer"

@export var text_speed = 1
@export var visible_length = 5.0
@export var label_position : Vector2 = Vector2(0,0)
var checked = false
var done = false

func _ready():
	checkpoint_inidicator.global_position = label_position

func _process(delta):
	if checked:
		checkpoint_inidicator.visible_ratio += text_speed*delta

	if done:
		checkpoint_inidicator.modulate.a -= text_speed*delta

func _on_body_entered(body):
	visible_timer.start(visible_length)
	checked = true

func _on_visible_timer_timeout():
	done = true
