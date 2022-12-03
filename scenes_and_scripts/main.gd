extends Node2D

onready var heads = $heads
onready var paintings = $paintings

var objects_to_place = []

func _ready():
	randomize()
	place_items()

func place_items():
	for child in heads.get_children():
		if child.place_randomly == true:
			objects_to_place.append(child)
	
	for child in paintings.get_children():
		if child.place_randomly == true:
			objects_to_place.append(child)
	
	var step_size = 360.0 / objects_to_place.size()
	
	objects_to_place.shuffle()
	
	var x = 0.0
	
	for object in objects_to_place:
		object.position.x = cos((x / 90) * PI/2) * 2500
		object.position.y = sin((x / 90) * PI/2) * 2500
		
		var size = object.frames.get_frame(object.animation, object.frame).get_size()
		var new_scale
		
		if size.x > size.y:
			new_scale = 500/size.x
		else:
			new_scale = 500/size.y
		
		new_scale *= .6 + float(randi() % 81)/100
		object.scale = Vector2(new_scale, new_scale)
		
		object.rotation_degrees = -20 + randi() % 41
		
		object.position += Vector2(-250 + randi() % 501, -250 + randi() % 501)
		
		x += step_size
