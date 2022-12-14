extends AnimatedSprite

onready var area = $area
onready var col = $area/CollisionShape2D

export var can_be_found = true
export var place_randomly = true

var searched_right_now = false
var mouse_in_this = false

var repositioned = false

var active = false

var radius
var width
var height

func _ready():
	width = get_sprite_frames().get_frame('default', 0).get_width()
	height = get_sprite_frames().get_frame('default', 0).get_height()
	
	if width > height:
		radius = get_sprite_frames().get_frame('default', 0).get_width() / 2
	else:
		radius = get_sprite_frames().get_frame('default', 0).get_height() / 2
		

func mouse_entered():
	mouse_in_this = true

func mouse_exited():
	mouse_in_this = false

func _on_area_area_entered(area):
	var area_parent = area.get_parent()
	
	if area_parent.repositioned == false:
		#print(name, ' got entered by ', area.get_parent().name)
		reposition()

func reposition():
	repositioned = true
