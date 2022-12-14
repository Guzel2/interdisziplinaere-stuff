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

func _ready():
	radius = get_sprite_frames().get_frame('default', 0).get_width() / 2

func _on_hover_over_animation_finished():
	if animation == "active":
		animation = "default"

func mouse_entered():
	animation = "active"
	
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
