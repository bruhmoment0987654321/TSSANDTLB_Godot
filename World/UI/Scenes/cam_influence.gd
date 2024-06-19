extends Area2D

func _on_body_entered(body):
	if body.is_in_group("Player"):
		Global.emit_set_camera_target(self)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		Global.emit_set_camera_target(body)
