extends Node2D

@onready var starting_position = $From
@onready var next_position = $To

@export var where_from : Vector2
@export var where_to : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	starting_position.global_position = where_from
	next_position.global_position = where_to

func _on_from_body_entered(body):
	body.global_position = next_position.global_position
