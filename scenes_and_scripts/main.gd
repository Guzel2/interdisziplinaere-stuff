extends Node2D

onready var player = $player
onready var heads = $heads
onready var space = $space
onready var paintings = $paintings
onready var jungle = $jungle

onready var main_groups = [heads, space, paintings, jungle]

onready var drawings = $drawings

var objects = []
var objects_to_place = []
var objects_to_find = []
var current_searched_objects = []
var num_of_objects_to_search = 3

var circle_num = 0
var current_step = 0

var positions_and_radius = []

func _ready():
	randomize()
	set_up()
	place_objects()
	choose_objects_to_search()
	
	update_ui()

func set_up():
	for group in main_groups:
		for child in group.get_children():
			objects.append(child)
			
			if child.place_randomly == true:
				objects_to_place.append(child)
			if child.can_be_found == true:
				objects_to_find.append(child)

func place_objects():
	objects_to_place.shuffle()
	
	while objects_to_place != []:
		var radius = float(1500 + circle_num * 650)
		var step_count = float(15 + circle_num * 10)
		var step_size = 360/step_count
		
		current_step = 0
		
		while current_step < step_count:
			if objects_to_place == []:
				break
			
			var object = objects_to_place.pop_front()
			
			var pos = get_pos_on_circle(current_step, step_size, radius)
			pos += Vector2(-250 + randi() % 501, -250 + randi() % 501)
			object.position = pos
			
			var size = object.frames.get_frame(object.animation, object.frame).get_size()
			var new_scale
			
			var obj_radius
			
			if size.x > size.y:
				new_scale = 500.0/size.x
				obj_radius = size.x/1.75
			else:
				new_scale = 500.0/size.y
				obj_radius = size.y/1.75
			object.radius = obj_radius
			
			new_scale *= .6 + float(randi() % 81)/100
			object.scale = Vector2(new_scale, new_scale)
			
			object.rotation_degrees = -20 + randi() % 41
			
			
			for position_to_check in positions_and_radius:
				var distance = position_to_check[0].distance_to(pos)
				
				if distance < position_to_check[1] or distance < obj_radius * new_scale:
					objects_to_place.append(object)
					print('reposition')
			
			positions_and_radius.append([pos, obj_radius * new_scale])
			
			current_step += 1
		
		circle_num += 1
	
	print(circle_num)

func get_pos_on_circle(step: float, step_size: float, radius: float):
	var pos = Vector2(0, 0)
	
	pos.x = cos((step*step_size/90.0) * PI/2.0) * radius
	pos.y = sin((step*step_size/90.0) * PI/2.0) * radius
	
	return pos

func choose_objects_to_search():
	objects_to_find.shuffle()
	
	for _x in range(num_of_objects_to_search):
		var object = objects_to_find.pop_front()
		current_searched_objects.append(object)
		objects_to_find.append(object)

func update_ui():
	for x in range(num_of_objects_to_search):
		var texture = current_searched_objects[x].get_sprite_frames().get_frame('default', 0)
		
		var desired_sprite_size = 200.0
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
			
			objects_to_place.append(current_searched_objects[object_num])
			
			current_searched_objects.remove(object_num)
			
			var object = objects_to_find.pop_front()
			current_searched_objects.append(object)
			objects_to_find.append(object)
			
			player.set_drawing_mode()
			
			update_ui()
