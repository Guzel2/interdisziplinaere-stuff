extends Node2D

onready var parent = get_parent()
onready var ui = $ui

onready var canvas = $canvas
onready var container = $canvas/container
onready var viewport = $canvas/container/viewport
onready var palette = $canvas/palette

var speed = 3

var sprites = []

var drawing_mode = false

var eraser = false
var pen_down = false
var prev_pos = null

var cooldown = 0.0
var cooltimer = 1.0/30

var img_number = 0

var color = Color(1, 1, 1, 1)

var picture_boarder = Vector2(256, 256)

var palette_active = false
var canvas_active = false

var all_lines_and_circles = []

var drawing_num = 0

var lines_to_delete = []
var deleted_lines = 0
var delete_cap = 10

var check_distance_time = .5
var check_distance_timer = check_distance_time

var window_size

var default_screen_size = Vector2(1920, 1080)

func _ready():
	for child in ui.get_children():
		if 'sprite' in child.name:
			sprites.append(child)
	
	window_size = OS.get_window_size()
	
	print(window_size)

func _process(delta):
	#Input.warp_mouse_position(get_viewport().size/2)
	#$Camera2D.position = get_global_mouse_position()
	if !drawing_mode:
		var local_mouse_pos = get_local_mouse_position()
		var mouse_length = local_mouse_pos.length()
		
		print(local_mouse_pos)
		
		if mouse_length > 20:
			var multiplier = ((window_size/default_screen_size) * .95)
			
			print(multiplier)
			
			Input.warp_mouse_position(window_size/2 + local_mouse_pos * multiplier)
			
			var move_dir = (get_global_mouse_position()-position)
			position += move_dir * delta * speed
		
		var length = position.length()
		var max_length = 500 + parent.circle_num * 650
		
		if length >= max_length:
			var back_dir = ((position - (position.normalized() * max_length))/max_length) * delta * speed * 5000
			position -= back_dir
		
		#1500 + circle_num * 650
		
		if Input.is_action_just_pressed("left_click"):
			parent.check_if_player_found_object()
		
		if check_distance_timer > 0:
			check_distance_timer -= delta
		else:
			check_distances()
			check_distance_timer = check_distance_time
	else:
		#pen
		if Input.is_action_just_pressed("left_click"):
			if canvas_active:
				pen_down = true
			
		if Input.is_action_just_released("left_click"):
			if canvas_active:
				pen_down = false
				prev_pos = null
			
			if palette_active:
				var pos = (get_local_mouse_position() - palette.position)
				var img = palette.get_texture().get_data()
				img.lock()
				color = img.get_pixel(pos.x, pos.y)
				img.unlock()
		
		if Input.is_action_just_pressed("right_click"):
			eraser = true
		if Input.is_action_just_released("right_click"):
			eraser = false
		
		#drawing
		if pen_down:
			if cooldown <= 0:
				var skipped = false
				var mouse_pos = get_local_mouse_position() - container.rect_position
				
				#draw lines
				if prev_pos != null:
					var dir = mouse_pos - prev_pos
					var distance = dir.length()
					
					if distance < 5: #makes sure there is a little distance between ends of a line
						skipped = true
					else:
						draw_line_on_canvas(mouse_pos, dir, distance)
				
				if prev_pos == null or skipped: #draw circles
					draw_circle_on_canvas(mouse_pos)
				
				if skipped == false:
					prev_pos = mouse_pos - canvas.position
					cooldown = cooltimer
			else:
				cooldown -= delta
		
		
	#clear delete queue
	deleted_lines = 0
	var checking = false
	
	if lines_to_delete != []:
		checking = true
	
	while checking:
		if lines_to_delete == []:
			checking = false
		else:
			var line = lines_to_delete.pop_front()
			
			line.queue_free_this()
			deleted_lines += 1
			
			if deleted_lines >= delete_cap:
				checking = false
	
func set_drawing_mode():
	drawing_mode = true
	canvas.visible = true
	ui.visible = false

func set_searching_mode():
	drawing_mode = false
	canvas.visible = false
	ui.visible = true

func check_distances():
	for object in parent.objects:
		if object.active:
			if (position - object.position).length() < object.radius * object.scale.x:
				if !object.mouse_in_this:
					object.mouse_entered()
			
			elif object.mouse_in_this:
				object.mouse_exited()

func draw_line_on_canvas(new_pos, dir, distance):
	var white_square = load("res://scenes_and_scripts/white_square.tscn").instance()
	var white_area = load("res://scenes_and_scripts/white_area.tscn").instance()
	viewport.add_child(white_square)
	canvas.add_child(white_area)
	all_lines_and_circles.append(white_area)
	
	white_square.rotation = dir.angle()
	white_square.position = new_pos-dir/2
	white_square.scale.x = distance/8
	white_square.modulate = color
	
	white_area.rotation = white_square.rotation
	white_area.position = white_square.position - Vector2(250, 250)
	white_area.scale.x = distance/8
	white_area.partner.append(white_square)
	
	#adding start and end circle
	var white_circle_1 = load("res://scenes_and_scripts/white_circle.tscn").instance()
	var white_circle_2 = load("res://scenes_and_scripts/white_circle.tscn").instance()
	viewport.add_child(white_circle_1)
	viewport.add_child(white_circle_2)
	
	white_circle_1.position = prev_pos
	white_circle_2.position = new_pos
	
	white_circle_1.modulate = color
	white_circle_2.modulate = color
	
	white_area.partner.append(white_circle_1)
	white_area.partner.append(white_circle_2)

func draw_circle_on_canvas(mouse_pos):
	var white_circle = load("res://scenes_and_scripts/white_circle.tscn").instance()
	var white_circle_area = load("res://scenes_and_scripts/white_area.tscn").instance()
	viewport.add_child(white_circle)
	canvas.add_child(white_circle_area)
	all_lines_and_circles.append(white_circle_area)
	
	white_circle.position = mouse_pos
	white_circle.modulate = color
	white_circle_area.position = white_circle.position - Vector2(250, 250)
	
	white_circle_area.scale.x = 2
	
	white_circle_area.partner.append(white_circle)

func save_drawing():
	var img = viewport.get_texture().get_data()
	img.flip_y()
	var path = "user://drawing_" + String(drawing_num) + ".png"
	img.save_png(path)
	
	drawing_num += 1
	
	clear_canvas()
	
	spawn_new_object(path, position)
	
	set_searching_mode()

func clear_canvas():
	for object in all_lines_and_circles:
		lines_to_delete.append(object)
	
	all_lines_and_circles.clear()

func spawn_new_object(path, pos):
	var basic_idle = load("res://scenes_and_scripts/basic_idle.tscn").instance()
	var sprite_frame = SpriteFrames.new()
	
	sprite_frame.add_frame('default', load_external_texture(path), 0)
	
	basic_idle.set_sprite_frames(sprite_frame)
	
	basic_idle.position = pos
	
	parent.drawings.add_child(basic_idle)
	parent.objects.append(basic_idle)
	parent.objects_to_find.append(basic_idle)
	parent.place_objects()

func load_external_texture(path):
	var image = Image.new()
	image.load(path)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	return texture


func _on_area_area_entered(area):
	if area.name == "area":
		area.get_parent().active = true

func _on_area_area_exited(area):
	if area.name == "area":
		area.get_parent().active = false


func _on_palette_area_mouse_entered():
	palette_active = true

func _on_palette_area_mouse_exited():
	palette_active = false


func _on_canvas_area_mouse_entered():
	canvas_active = true

func _on_canvas_area_mouse_exited():
	canvas_active = false
	if pen_down:
		var mouse_pos = get_local_mouse_position() - container.rect_position
		var dir = mouse_pos - prev_pos
		var distance = dir.length()
		draw_line_on_canvas(mouse_pos, dir, distance)
		
		pen_down = false
		prev_pos = null


func _on_delete_all_button_up():
	clear_canvas()

func _on_save_button_up():
	if !all_lines_and_circles.empty():
		save_drawing()
