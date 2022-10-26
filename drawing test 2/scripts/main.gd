extends Node2D

onready var container = $container
onready var viewport = $container/viewport

var eraser = false
var pen_down = false
var prev_pos = null

var cooldown = 0.0
var cooltimer = 1.0/60

var img_number = 0

var hue = 0.0
var color = Color(1, 1, 1, 1)

func _process(delta):
	
	#eraser
	if Input.is_action_just_pressed("right_click"):
		eraser = true
	if Input.is_action_just_released("right_click"):
		eraser = false
	
	#pen
	if Input.is_action_just_pressed("left_click"):
		pen_down = true
	if Input.is_action_just_released("left_click"):
		pen_down = false
		prev_pos = null
	
	if pen_down:
		if cooldown <= 0:
			var skipped = false
			
			#draw lines
			if prev_pos != null:
				var dir = get_global_mouse_position() - prev_pos
				var distance = dir.length()
				
				if distance < 5: #makes sure there is a little distance between ends of a line
					skipped = true
				else:
					var white_square = load("res://scripts/white_square.tscn").instance()
					var white_area = load("res://scripts/white_area.tscn").instance()
					viewport.add_child(white_square)
					self.add_child(white_area)
					
					white_square.rotation = dir.angle()
					white_square.position = get_global_mouse_position()-dir/2
					white_square.scale.x = distance/8
					white_square.modulate = color
					
					white_area.rotation = white_square.rotation
					white_area.position = white_square.position
					white_area.scale.x = distance/8
					white_area.partner.append(white_square)
					
					#adding start and end circle
					var white_circle_1 = load("res://scripts/white_circle.tscn").instance()
					var white_circle_2 = load("res://scripts/white_circle.tscn").instance()
					viewport.add_child(white_circle_1)
					viewport.add_child(white_circle_2)
					
					white_circle_1.position = prev_pos
					white_circle_2.position = get_global_mouse_position()
					
					white_circle_1.modulate = color
					white_circle_2.modulate = color
					
					white_area.partner.append(white_circle_1)
					white_area.partner.append(white_circle_2)
			
			if prev_pos == null or skipped: #draw circles
				var white_circle = load("res://scripts/white_circle.tscn").instance()
				var white_circle_area = load("res://scripts/white_area.tscn").instance()
				viewport.add_child(white_circle)
				self.add_child(white_circle_area)
				
				white_circle.position = get_global_mouse_position()
				white_circle.modulate = color
				white_circle_area.position = white_circle.position
				
				white_circle_area.scale.x = 2
				
				white_circle_area.partner.append(white_circle)
			
			if skipped == false:
				prev_pos = get_global_mouse_position()
				cooldown = cooltimer
		else:
			cooldown -= delta
	
	
	#saving
	if Input.is_action_just_pressed("middle_click"):
		save()
		print('just_saved')
	
	#color
	if Input.is_action_just_released("scroll_up"):
		hue += .1
	if Input.is_action_just_released("scroll_down"):
		hue -= .1
	
	if hue < 0:
		hue = 1
	if hue > 1:
		hue = 0
	
	color = Color.from_hsv(hue, 1, 1, 1)

func save():
	var img = viewport.get_texture().get_data()
	img.flip_y()
	img.save_png("sprites/drawings/new" + String(img_number) + ".png")
	img_number += 1
	for child in viewport.get_children():
		child.queue_free()

