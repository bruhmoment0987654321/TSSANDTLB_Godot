extends Node

signal set_camera_target(entity : Node2D)

func emit_set_camera_target(entity : Node2D) -> void:
	set_camera_target.emit(entity)
