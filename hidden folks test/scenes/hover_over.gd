extends AnimatedSprite

onready var area = $area
onready var col = $area/CollisionShape2D
var active = false

export var area_size = 100

func _ready():
	col.shape.radius = area_size

func _on_area_mouse_entered():
	animation = "active"

func _on_hover_over_animation_finished():
	if animation == "active":
		animation = "idle"