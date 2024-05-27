extends Area2D

func _on_body_entered(body):
	if body.is_in_group("Player"):
			$AnimationPlayer.play("revealed")
			await $AnimationPlayer.animation_finished


func _on_body_exited(body):
	$AnimationPlayer.play("hidden")
