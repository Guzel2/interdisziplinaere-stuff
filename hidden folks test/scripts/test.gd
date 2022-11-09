extends Sprite

onready var parent = get_parent()
onready var sibling = parent.get_children()[0]

var desired_size = 200.0

func _ready():
	texture = sibling.get_sprite_frames().get_frame('idle', 0)
	
	
	var height = get_texture().get_height()
	var width = get_texture().get_width()
	
	if height > width:
		scale.x = desired_size/height
		scale.y = desired_size/height
	else:
		scale.x = desired_size/width
		scale.y = desired_size/width
	
	
	
