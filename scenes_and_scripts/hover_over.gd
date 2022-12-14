extends AnimatedSprite

onready var area = $area
onready var col = $area/CollisionShape2D

export var area_size = 1.0
export var can_be_found = true
export var place_randomly = true

var searched_right_now = false
var mouse_in_this = false

var repositioned = false

func change_radius():
	col.shape.set_radius(area_size * 500.0)

func _on_area_mouse_entered():
	animation = "active"
	
	mouse_in_this = true
	
	print(name, ' has a radius of ', col.shape.radius, ' and should have a radius of ', area_size * 500.0)
	if col.shape.radius != area_size * 500.0:
		change_radius()

func _on_area_mouse_exited():
	mouse_in_this = false

func _on_hover_over_animation_finished():
	if animation == "active":
		animation = "default"


func _on_area_area_entered(area):
	var area_parent = area.get_parent()
	
	if area_parent.repositioned == false:
		#print(name, ' got entered by ', area.get_parent().name)
		reposition()

func reposition():
	repositioned = true
