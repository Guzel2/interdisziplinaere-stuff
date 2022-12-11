extends AnimatedSprite

onready var area = $area
onready var col = $area/CollisionShape2D
var active = false

export var area_size = 1.0
export var can_be_found = true
export var place_randomly = false

var searched_right_now = false
var mouse_in_this = false

func _ready():
	col.shape.radius = area_size * 500.0

func _on_area_mouse_entered():
	animation = "active"
	
	mouse_in_this = true

func _on_area_mouse_exited():
	mouse_in_this = false

func _on_hover_over_animation_finished():
	if animation == "active":
		animation = "default"
