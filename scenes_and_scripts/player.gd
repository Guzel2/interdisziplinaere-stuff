extends Node2D

onready var parent = get_parent()
onready var ui = $ui

onready var canvas = $canvas
onready var container = $canvas/container
onready var viewport = $canvas/container/viewport

var speed = 3

var sprites = []

var drawing_mode = false

var eraser = false
var pen_down = false
var prev_pos = null

var cooldown = 0.0
var cooltimer = 1.0/60

var img_number = 0

var hue = 0.0
var color = Color(1, 1, 1, 1)

var picture_boarder = Vector2(256, 256)

func _ready():
	for child in ui.get_children():
		if 'sprite' in child.name:
			sprites.append(child)

func _process(delta):
	
	#Input.warp_mouse_position(get_viewport().size/2)
	#$Camera2D.position = get_global_mouse_position()
	if !drawing_mode:
		if position.distance_to(get_global_mouse_position()) > 20:
			if get_local_mouse_position().length() > 20:
				Input.warp_mouse_position(get_viewport().size/2 + get_local_mouse_position() - get_local_mouse_position()*.05)
			var move_dir = (get_global_mouse_position()-position)
			position += move_dir * delta * speed
		
		
		if Input.is_action_just_pressed("left_click"):
			parent.check_if_player_found_object()
		
		check_distances()
		
	else:
		#pen
		if Input.is_action_just_pressed("left_click"):
			pen_down = true
		if Input.is_action_just_released("left_click"):
			pen_down = false
			prev_pos = null
		
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
						var white_square = load("res://scenes_and_scripts/white_square.tscn").instance()
						var white_area = load("res://scenes_and_scripts/white_area.tscn").instance()
						viewport.add_child(white_square)
						canvas.add_child(white_area)
						
						white_square.rotation = dir.angle()
						white_square.position = mouse_pos-dir/2
						white_square.scale.x = distance/8
						white_square.modulate = color
						
						white_area.rotation = white_square.rotation
						white_area.position = white_square.position
						white_area.scale.x = distance/8
						white_area.partner.append(white_square)
						
						#adding start and end circle
						var white_circle_1 = load("res://scenes_and_scripts/white_circle.tscn").instance()
						var white_circle_2 = load("res://scenes_and_scripts/white_circle.tscn").instance()
						viewport.add_child(white_circle_1)
						viewport.add_child(white_circle_2)
						
						white_circle_1.position = prev_pos
						white_circle_2.position = mouse_pos
						
						white_circle_1.modulate = color
						white_circle_2.modulate = color
						
						white_area.partner.append(white_circle_1)
						white_area.partner.append(white_circle_2)
				
				if prev_pos == null or skipped: #draw circles
					var white_circle = load("res://scenes_and_scripts/white_circle.tscn").instance()
					var white_circle_area = load("res://scenes_and_scripts/white_area.tscn").instance()
					viewport.add_child(white_circle)
					canvas.add_child(white_circle_area)
					
					white_circle.position = mouse_pos
					white_circle.modulate = color
					white_circle_area.position = white_circle.position
					
					white_circle_area.scale.x = 2
					
					white_circle_area.partner.append(white_circle)
				
				if skipped == false:
					prev_pos = mouse_pos - canvas.position
					cooldown = cooltimer
			else:
				cooldown -= delta
	
func set_drawing_mode():
	drawing_mode = true
	canvas.visible = true

func check_distances():
	for object in parent.objects:
		if object.active:
			if (position - object.position).length() < object.radius * object.scale.x:
				if !object.mouse_in_this:
					object.mouse_entered()
			
			elif object.mouse_in_this:
				object.mouse_exited()

func _on_area_area_entered(area):
	area.get_parent().active = true

func _on_area_area_exited(area):
	area.get_parent().active = false
