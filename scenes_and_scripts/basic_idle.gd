extends AnimatedSprite

onready var area = $area
onready var col = $area/CollisionShape2D

export var area_size = 1.0

func _ready():
	col.shape.radius = area_size * 500.0
