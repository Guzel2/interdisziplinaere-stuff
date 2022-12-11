extends Node2D

onready var player = $player
onready var heads = $heads
onready var paintings = $paintings

var objects_to_place = []
var objects_to_find = []
var current_searched_objects = []
var num_of_objects_to_search = 3

func _ready():
	randomize()
	set_up()
	place_objects()
	choose_objects_to_search()
	
	update_ui()

func set_up():
	for child in heads.get_children():
		if child.place_randomly == true:
			objects_to_place.append(child)
		if child.can_be_found == true:
			objects_to_find.append(child)
	
	for child in paintings.get_children():
		if child.place_randomly == true:
			objects_to_place.append(child)
		if child.can_be_found == true:
			objects_to_find.append(child)

func place_objects():
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

func choose_objects_to_search():
	objects_to_find.shuffle()
	
	for x in range(num_of_objects_to_search):
		var object = objects_to_find.pop_front()
		current_searched_objects.append(object)
		objects_to_find.append(object)

func update_ui():
	for x in range(num_of_objects_to_search):
		var texture = current_searched_objects[x].get_sprite_frames().get_frame('default', 0)
		
		var desired_sprite_size = 300.0
		var new_scale
		
		if texture.get_height() > texture.get_width():
			new_scale = desired_sprite_size/texture.get_height()
		else:
			new_scale = desired_sprite_size/texture.get_width()
		
		player.sprites[x].texture = texture
		player.sprites[x].scale = Vector2(new_scale, new_scale)

func check_if_player_found_object():
	for object_num in range(current_searched_objects.size()):
		if current_searched_objects[object_num].mouse_in_this == true:
			print('yay you found an object')
			
			current_searched_objects.remove(object_num)
			
			var object = objects_to_find.pop_front()
			current_searched_objects.append(object)
			objects_to_find.append(object)
			
			player.set_drawing_mode()
			
			update_ui()
