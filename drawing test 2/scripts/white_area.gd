extends Area2D

onready var parent = get_parent()
onready var col = $CollisionShape2D

var partner = []

func _on_white_area_mouse_entered():
	if parent.eraser:
		queue_free()
		for part in partner:
			part.queue_free()
		print('test')
	
