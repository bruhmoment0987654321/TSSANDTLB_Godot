extends Marker2D

@export var popup_label : PackedScene
@export var displayed_text : String

func popup():
	var inst = popup_label.instantiate()
	inst.text = displayed_text
	inst.position = global_position
	get_tree().current_scene.add_child(inst)

func _process(delta):
	#oopsie. adding ball was by accident. it was from 
	#a reddit post by userFromNextDoor
	#Thanks CowThing ,_,
	for ball in get_tree().get_nodes_in_group("Floating Text"):
		ball.pivot_offset = Vector2(ball.size/2)
		ball.position = global_position - Vector2(ball.size/2)
