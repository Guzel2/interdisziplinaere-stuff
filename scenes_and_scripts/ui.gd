extends Node2D

onready var parent = get_parent()
onready var arrows = [$arrow1, $arrow2, $arrow3] 

func _process(_delta):
	for object in parent.parent.current_searched_objects.size():
		if parent.parent.current_searched_objects[object].active:
			arrows[object].visible = false
		else:
			arrows[object].visible = true
			arrows[object].rotation = parent.position.angle_to_point(parent.parent.current_searched_objects[object].position)
