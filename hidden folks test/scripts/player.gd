extends Node2D


func _process(delta):
	
	#Input.warp_mouse_position(get_viewport().size/2)
	#$Camera2D.position = get_global_mouse_position()
	
	if position.distance_to(get_global_mouse_position()) > 20:
		if get_local_mouse_position().length() > 20:
			Input.warp_mouse_position(get_viewport().size/2 + get_local_mouse_position()*2 - get_local_mouse_position()*.1)
		var move_dir = (get_global_mouse_position()-position)
		position += move_dir * delta * 2
		

	if Input.is_action_just_pressed("left_click"):
		Input.warp_mouse_position(get_viewport().size/2)
	
